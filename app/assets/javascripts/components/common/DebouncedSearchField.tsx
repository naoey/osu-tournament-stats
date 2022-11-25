import { Input } from "antd";
import * as qs from "query-string";
import React, { useState } from "react";

interface IDebouncedSearchFieldProps {
  onSearch: (query: string) => void;
  placeholder?: string;
  searchQueryKey?: string;
  timeout?: number;
}

export function DebouncedSearchField(props: IDebouncedSearchFieldProps) {
  const { onSearch, timeout, searchQueryKey, ...rest } = props;
  const [value, setValue] = useState<string | undefined>((qs.parse(window.location.search))[searchQueryKey ?? ""] as string);

  let timer: ReturnType<typeof setTimeout>;

  const onSearchQueryChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const query = e.target.value;

    setValue(query);

    if (timer) clearTimeout(timer);

    timer = setTimeout(() => onSearch(query), timeout);
  };

  return (
    <Input.Search
      {...rest}
      value={value ?? undefined}
      onChange={onSearchQueryChange}
    />
  );
}
