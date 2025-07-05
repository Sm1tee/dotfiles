/// <reference types="node" />
import { DownloadItem, DownloadManager as IDownloadManager, HookType, AsyncHookCallback, AsyncErrorCallback } from './interfaces';
export declare class DownloadManager implements IDownloadManager {
    private concurrency_;
    private lastId_;
    private inProgressSize_;
    private downloadQueue_;
    private queuePaused_;
    private downloadBuffer_;
    private queueRemove_;
    private queueProcessNext_;
    constructor(concurrency?: number);
    download(uri: string, name: string, filename: string, downloadPath?: string, customData?: {
        [key: string]: string | number | boolean | Buffer;
    }): DownloadItem;
    interrupt(downloadItemId: number): void;
    remove(downloadItemId: number): void;
    run(): void;
    stop(): void;
    clear(): void;
    size(): number;
    list(): DownloadItem[];
    inProgressSize(): number;
    private listeners_;
    private errorListeners_;
    private emit_;
    private emitError_;
    on(type: HookType, callback: AsyncHookCallback): void;
    removeListener(type: HookType, callback: AsyncHookCallback): void;
    onError(callback: AsyncErrorCallback): void;
    removeErrorListener(callback: AsyncErrorCallback): void;
}
