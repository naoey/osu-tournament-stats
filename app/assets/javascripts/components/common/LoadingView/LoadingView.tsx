import React from 'react';
import { Button, Spin } from "antd";

import './LoadingView.scss';

export type LoadingViewProps = {
  message?: string;
  failed?: boolean;
  onRetry?: () => void;
}

export function LoadingView({
  message,
  failed,
  onRetry,
}: LoadingViewProps) {
  const renderIcon = () => {
    if (failed && typeof onRetry === 'function')
      return (
        <Button onClick={onRetry} className="retry-button">
          <i className="material-icons">retry</i>
        </Button>
      );

    if (failed)
      return <i className="failed-icon">retry</i>;

    return <Spin size="large" />;
  };

  const renderMessage = () => {
    if (message === undefined || typeof message !== 'string')
      return <h4>Loading...</h4>;

    if (message === null)
      return null;

    return <h4>{message}</h4>;
  }

  return (
    <div className="loading-wrapper">
      {renderIcon()}
      {renderMessage()}
    </div>
  );
}
