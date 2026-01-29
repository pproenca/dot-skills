---
title: Combine context with reducers for complex state
impact: MEDIUM
impactDescription: For state that's both global and has complex updates, provide both state and dispatch through context
tags: [context, reducers, global-state, dispatch, patterns]
---

# Combine Context with Reducers for Complex State

When you need both global access (context) and complex state logic (reducer), combine them. Provide both the state and dispatch function through context.

## The Pattern

```tsx
// TasksContext.tsx
import { createContext, useContext, useReducer } from 'react';

// Types
type Task = { id: number; text: string; done: boolean };
type Action =
  | { type: 'added'; text: string }
  | { type: 'changed'; task: Task }
  | { type: 'deleted'; id: number };

// Contexts (split for performance)
const TasksContext = createContext<Task[]>([]);
const TasksDispatchContext = createContext<React.Dispatch<Action>>(() => {});

// Reducer
function tasksReducer(tasks: Task[], action: Action): Task[] {
  switch (action.type) {
    case 'added':
      return [...tasks, { id: Date.now(), text: action.text, done: false }];
    case 'changed':
      return tasks.map(t => t.id === action.task.id ? action.task : t);
    case 'deleted':
      return tasks.filter(t => t.id !== action.id);
  }
}

// Provider component
export function TasksProvider({ children }: { children: React.ReactNode }) {
  const [tasks, dispatch] = useReducer(tasksReducer, []);

  return (
    <TasksContext value={tasks}>
      <TasksDispatchContext value={dispatch}>
        {children}
      </TasksDispatchContext>
    </TasksContext>
  );
}

// Custom hooks
export function useTasks() {
  return useContext(TasksContext);
}

export function useTasksDispatch() {
  return useContext(TasksDispatchContext);
}
```

## Usage in App

```tsx
// App.tsx
import { TasksProvider } from './TasksContext';

function App() {
  return (
    <TasksProvider>
      <h1>Tasks</h1>
      <AddTask />
      <TaskList />
    </TasksProvider>
  );
}
```

## Usage in Components

```tsx
// AddTask.tsx
import { useTasksDispatch } from './TasksContext';

function AddTask() {
  const [text, setText] = useState('');
  const dispatch = useTasksDispatch();

  function handleAdd() {
    dispatch({ type: 'added', text });
    setText('');
  }

  return (
    <div>
      <input value={text} onChange={e => setText(e.target.value)} />
      <button onClick={handleAdd}>Add</button>
    </div>
  );
}
```

```tsx
// TaskList.tsx
import { useTasks, useTasksDispatch } from './TasksContext';

function TaskList() {
  const tasks = useTasks();
  const dispatch = useTasksDispatch();

  return (
    <ul>
      {tasks.map(task => (
        <li key={task.id}>
          <input
            type="checkbox"
            checked={task.done}
            onChange={() => dispatch({
              type: 'changed',
              task: { ...task, done: !task.done },
            })}
          />
          {task.text}
          <button onClick={() => dispatch({ type: 'deleted', id: task.id })}>
            Delete
          </button>
        </li>
      ))}
    </ul>
  );
}
```

## Why Split Contexts?

```tsx
// Splitting state and dispatch contexts prevents unnecessary re-renders

// Components that only dispatch don't re-render when state changes
function AddTask() {
  const dispatch = useTasksDispatch();
  // Only re-renders if dispatch changes (it won't, it's stable)
}

// Components that only read state re-render when state changes
function TaskCount() {
  const tasks = useTasks();
  return <span>{tasks.length} tasks</span>;
}

// If combined, AddTask would re-render on every state change
```

## Alternative: Single Combined Context

```tsx
// For simpler cases, a single context is fine
type TasksContextType = {
  tasks: Task[];
  dispatch: React.Dispatch<Action>;
};

const TasksContext = createContext<TasksContextType | null>(null);

export function TasksProvider({ children }) {
  const [tasks, dispatch] = useReducer(tasksReducer, []);

  return (
    <TasksContext value={{ tasks, dispatch }}>
      {children}
    </TasksContext>
  );
}

export function useTasks() {
  const context = useContext(TasksContext);
  if (!context) throw new Error('useTasks must be within TasksProvider');
  return context;
}
```

## Key Principle

Context provides global access. Reducers provide organized state updates. Together they create a clean architecture for complex app-wide state.
