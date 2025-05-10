import { useState, createContext, useContext, ReactNode } from "react";

type LoadingTrackerContext = {
  isKeyLoading: (key: string) => boolean;
  addLoadingKey: (key: string) => void;
  removeLoadingKey: (key: string) => void;
}

const LoadingContext = createContext<LoadingTrackerContext | null>(null);

type LoadingTrackerProps = {
  children: ReactNode,
};

export default function LoadingTracker({ children }: LoadingTrackerProps) {
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

export const useLoadingTracker = () => {
  const context = useContext(LoadingContext);

  if (context === null)
    throw new Error("`useLoadingTracker` can't be used outside a loading context");

  return context;
};
