namespace py gen.twitter.thermos

enum ProcessState {
  // normal state
  WAITING   = 0   // blocked on execution dependencies or footprint restrictions
  FORKED    = 1   // starting, need to wait for signal from Process that it's running
  RUNNING   = 2   // currently running
  SUCCESS   = 3   // returncode == 0
  KILLED    = 4   // Killed by user action or task failure, runner teardown.

  // abnormal states
  FAILED    = 5   // returncode != 0
  LOST      = 6   // the coordinator either died or some condition caused us to lose it
                  // e.g. reboot.
}

struct ProcessStatus {
  // Sequence number, must be monotonically increasing for all
  // ProcessState messages for a particular process across all runs.
  1: i64             seq

  // Process name
  3: string          process

  5: ProcessState    state

  // WAITING -> FORKED
 10: i32             coordinator_pid
 11: double          fork_time

  // FORKED -> RUNNING
  6: double          start_time
  7: i32             pid

  // RUNNING -> {FINISHED, FAILED, KILLED}
  8: double          stop_time
  9: i32             return_code

  // {FORKED, RUNNING} -> LOST nothing happens.  this ProcessState ceases to exist.
  // Doesn't count against the run total.
}

enum TaskState {
  ACTIVE   = 0
  SUCCESS  = 1
  FAILED   = 2
  KILLED   = 3
}

struct TaskStatus {
  1: TaskState state
  2: i64       timestamp_ms
  3: i32       runner_pid
}

// The first framed message in the Ckpt stream.
struct RunnerHeader {
  1: string task_id
  2: i64    launch_time_ms  // kill this
  3: string sandbox
  4: string hostname        // kill this
  5: string user
  6: map<string, i64> ports
}

union RunnerCkpt {
  1: RunnerHeader       runner_header
  2: ProcessStatus      process_status
  3: TaskStatus         task_status
}

struct RunnerState {
  1: RunnerHeader header
  2: list<TaskStatus> statuses
  3: map<string, list<ProcessStatus>> processes
}
