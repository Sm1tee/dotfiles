/// <reference types="node" />
export declare enum DownloadItemState {
    PENDING = "pending",
    IN_PROGRESS = "in_progress",
    INTERRUPTED = "interrupted",
    COMPLETE = "complete",
    ERROR = "error"
}
export declare type DownloadItem = {
    id: number;
    name: string;
    state: DownloadItemState;
    filename: string;
    downloadPath: string;
    uri: string;
    bytes: Buffer | null;
    size: number;
    downloadedSize: number;
    startMs: number;
    customData?: {
        [key: string]: number | string | boolean | Buffer;
    };
};
export declare type HookType = 'add' | 'interrupted' | 'progress' | 'complete';
export declare type AsyncHookCallback = (item: DownloadItem) => Promise<void>;
export declare type AsyncErrorCallback = (item: DownloadItem, err: Error) => Promise<void>;
export interface DownloadManager {
    download(uri: string, name: string, filename: string, downloadPath?: string): DownloadItem;
    interrupt(downloadItemId: number): void;
    remove(downloadItemId: number): void;
    run(): void;
    stop(): void;
    clear(): void;
    size(): number;
    inProgressSize(): number;
    on(type: HookType, callback: AsyncHookCallback): void;
    removeListener(type: HookType, callback: AsyncHookCallback): void;
    onError(callback: AsyncErrorCallback): void;
    removeErrorListener(callback: AsyncErrorCallback): void;
}
