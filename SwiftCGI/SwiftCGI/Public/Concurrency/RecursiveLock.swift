// Copyright 2015 Tony Allevato
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Darwin


/// A reentrant mutual exclusion lock implemented using a pthread mutex.
///
/// While this class provides individual `acquire` and `release` operations, it is recommended to
/// use the `synchronized` method to acquire the lock and execute a block, while ensuring that the
/// lock is released even if the block throws an error.
public class RecursiveLock {

  /// The attributes of the pthread mutex.
  private var mutexAttr = pthread_mutexattr_t()

  /// The low-level pthread mutex structure. Visible internally so it can be accessed from the
  /// `Condition` type.
  var mutex = pthread_mutex_t()

  /// Creates a new mutex.
  public init() {
    pthread_mutexattr_init(&mutexAttr)
    pthread_mutexattr_settype(&mutexAttr, PTHREAD_MUTEX_RECURSIVE)
    pthread_mutex_init(&mutex, &mutexAttr)
  }

  deinit {
    pthread_mutex_destroy(&mutex)
    pthread_mutexattr_destroy(&mutexAttr)
  }

  /// Acquires the lock.
  ///
  /// If no thread holds the lock, it is acquired, its hold count is set to one, and the method
  /// returns.
  ///
  /// If the current thread holds the lock, then its hold count is incremented and the method
  /// returns.
  ///
  /// If a different thread holds the lock, then the current thread blocks until the lock is
  /// released by its owner and it is able to try again to acquire it.
  public func acquire() {
    pthread_mutex_lock(&mutex)
  }

  /// Releases the lock.
  ///
  /// This method decrements the lock's hold coun by one. If it reaches zero, the lock is released,
  /// causing any other threads waiting to acquire it to do so.
  public func release() {
    pthread_mutex_unlock(&mutex)
  }

  /// Acquires the lock, executes the given function, and then releases the lock.
  ///
  /// This method is safer than using the `acquire`/`release` operations directly since it ensures
  /// that the lock is property released under error conditions.
  public func synchronized<Result>(@noescape function: () throws -> Result) rethrows -> Result {
    acquire()
    defer {
      release()
    }
    return try function()
  }

  /// Creates and returns a `Condition` that is bound to this lock.
  ///
  /// - Returns: A new `Condition` that is bound to this lock.
  public func newCondition() -> Condition {
    return Condition(owningLock: self)
  }
}
