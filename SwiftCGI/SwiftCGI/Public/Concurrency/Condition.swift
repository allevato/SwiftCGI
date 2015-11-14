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


/// A concurrency primitive that threads can wait on, continuing execution when another thread
/// signals the condition.
///
/// `Condition` objects cannot be created on their own. Retrieve one by calling the
/// `RecursiveLock.newCondition` method, which associates the condition with the lock; that is,
/// waiting on the condition will atomically release the lock before waiting on the condition, and
/// then atomically re-acquire it after the thread is unblocked.
public class Condition {

  /// The low-level pthread condition variable structure.
  private var cond = pthread_cond_t()

  /// The lock from which this condition was created.
  private var owningLock: RecursiveLock

  /// Created a new condition variable.
  init(owningLock: RecursiveLock) {
    self.owningLock = owningLock
    pthread_cond_init(&cond, nil)
  }

  deinit {
    pthread_cond_destroy(&cond)
  }

  /// Blocks the calling thread until the condition is signaled.
  public func wait() {
    pthread_cond_wait(&cond, &owningLock.mutex)
  }

  /// Unblocks at least one thread currently waiting on this condition.
  public func signal() {
    pthread_cond_signal(&cond)
  }

  /// Unblocks all threads currently waiting on this condition.
  public func signalAll() {
    pthread_cond_broadcast(&cond)
  }
}
