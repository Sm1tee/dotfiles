import { DownloadManager } from './services/download-manager';
import { UserSettings } from './services/user-settings';
declare type ErrorCallback = (err: Error) => void;
export declare class BackgroundApiService {
    private yandexMusicApi;
    static userSettings: UserSettings;
    static downloadManager: DownloadManager;
    private static errorListeners_;
    private static completeEventCallback_;
    protected static instance_: BackgroundApiService | null;
    static getInstance(locale: string): Promise<BackgroundApiService>;
    private constructor();
    private static emitError_;
    private static downloadCover_;
    private static processDownloadItem_;
    private static encodeFilename_;
    private static encodeFolderName_;
    private static generateTrackFilename_;
    static onError(callback: ErrorCallback): void;
    static removeErrorListener(callback: ErrorCallback): void;
    downloadTrack(trackId: number): Promise<void>;
    downloadAlbum(albumId: number): Promise<void>;
    downloadPlaylist(owner: string | number, kind: number): Promise<void>;
    downloadArtist(artistId: number): Promise<void>;
}
export {};
