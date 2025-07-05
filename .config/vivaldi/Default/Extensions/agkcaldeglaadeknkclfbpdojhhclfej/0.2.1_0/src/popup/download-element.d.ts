import { DownloadItem } from '../background/services/download-manager/interfaces';
export declare class HTMLDownloadElement extends HTMLElement {
    private static isInited;
    private downloadItem_;
    private error_;
    private stateIconElement_;
    private nameElement_;
    private estimatedTimeLeftElement_;
    private downloadSpeedElement_;
    private stateIconStyle_;
    private trimNameToLength_;
    private getEstimatedTime_;
    private getSpeed_;
    private init_;
    constructor(downloadItem: DownloadItem);
    get downloadItem(): DownloadItem;
    update(downloadItem: DownloadItem): void;
    setError(err: Error): void;
    getError(): Error | null;
}
