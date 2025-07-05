import { UserSettings as IUserSettings } from './interfaces';
export declare class UserSettings implements IUserSettings {
    coverSize: number;
    filenameFormat: string;
    downloadPath: string;
    downloadAlbumsInSeparateFolder: boolean;
    downloadPlaylistsInSeparateFolder: boolean;
    downloadArtistsInSeparateFolder: boolean;
    maxQueueSize: number;
    concurrency: number;
    constructor();
    load(): Promise<void>;
    save(): Promise<void>;
}
