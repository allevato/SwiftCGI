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


/// Controls a thread of execution.
///
/// This class cannot be instantiated directly. Instead, use the `threaded` function to provide the
/// closure or function that should be executed on a new thread; `threaded` returns the instance of
/// `Thread` that can be used to reference it later. For example,
///
///     var thread = threaded {
///       // Perform a long-running task in a background thread.
///     }
///     // Block until the thread finishes executing.
///     thread.join()
///
/// - SeeAlso: `threaded()`
public class Thread {

  /// The low-level pthread thread structure.
  private var thread = pthread_t()

  /// The function to be executed on a separate thread.
  private var function: () -> ()

  /// Creates a new thread object that will execute the given function.
  ///
  /// The thread is not started automatically; its `start` method must be called to start it.
  ///
  /// - Parameter function: The function to execute when the thread is started.
  private init(function: () -> ()) {
    self.function = function
  }

  /// Starts the thread, executing the receiver's function.
  private func start() {
    let retainedSelf = UnsafeMutablePointer<Void>(Unmanaged.passRetained(self).toOpaque())
    pthread_create(&thread, nil, { arg in
      let self_ = Unmanaged<Thread>.fromOpaque(COpaquePointer(arg)).takeRetainedValue()
      self_.function()
      return nil
    }, retainedSelf)
  }

  /// Blocks the calling thread until the receiver's thread has finished executing.
  public func join() {
    pthread_join(thread, nil)
  }
}


/// Executes the given closure or function on a new thread.
///
/// - Parameter function: The closure or function to be executed on a new thread.
/// - Returns: A `Thread` object that can be used later to control the thread.
public func threaded(function: () -> ()) -> Thread {
  let thread = Thread(function: function)
  thread.start()
  return thread
}
