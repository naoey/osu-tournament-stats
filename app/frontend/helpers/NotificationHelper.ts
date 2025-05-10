const listeners = new Map();

export default {
  /**
   * Dispatch an event.
   *
   * @param name Name of the event.
   * @param payload Data to be included in the event.
   */
  dispatch(name: string, payload: any) {
    document.dispatchEvent(
      new CustomEvent(
        name,
        { detail: payload }
      )
    );
  },

  subscribe<T>(name: string, handler: (payload: T) => void) {
    const cb = (e: Event) => handler.call(null, (e as CustomEvent).detail as T);

    listeners.set(handler, cb);

    document.addEventListener(name, cb);
  },

  unsubscribe<T>(name: string, handler: (payload: T) => void) {
    const cb = listeners.get(handler);
    listeners.delete(handler);

    document.removeEventListener(name, cb);
  }
};
