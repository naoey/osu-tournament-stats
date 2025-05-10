import { useState, createContext, useContext } from "react";

type LoadingTrackerContext = {
  isKeyLoading: (key: string) => void;
  addLoadingKey: (key: string) => void;
  removeLoadingKey: (key: string) => void;
}

const LoadingContext = createContext<LoadingTrackerContext>({});

export default function LoadingTracker({ children }) {
  const [loadingKeys, setLoadingKeys] = useState<string[]>([]);

  const isKeyLoading = (key: string) => loadingKeys.includes(key);

  const addLoadingKey = (key: string) => !isKeyLoading(key) && setLoadingKeys([...loadingKeys, key]);

  const removeLoadingKey = (key: string) => setLoadingKeys(loadingKeys.filter(k => k !== key));

  return (
    <LoadingContext.Provider value={{ isKeyLoading, addLoadingKey, removeLoadingKey }}>
      {children}
    </LoadingContext.Provider>
  );
}

export const useLoadingTracker = () => useContext(LoadingContext);
