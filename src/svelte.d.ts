declare module "*.svelte";
declare namespace svelteHTML {
  interface IntrinsicElements {
    [key: string]: any;
  }
  interface HTMLAttributes<T> {
    [key: string]: any;
  }
} 