import { Track, Album, Playlist, Artist, Lyric, YandexMusicAPI as IYandexMusicAPI } from './interfaces';
export declare class YandexMusicAPI implements IYandexMusicAPI {
    protected static availableLocales_: string[];
    protected locale_: string;
    protected headers_: {
        [header: string]: string;
    };
    private getHostname;
    private getObject;
    constructor(locale?: string);
    getTrack(trackId: number): Promise<{
        readonly artists: Artist[];
        readonly otherVersions: {
            [version: string]: Track[];
        };
        readonly alsoInAlbums: Album[];
        readonly similarTracks: Track[];
        readonly track: Track;
        readonly lyric: Lyric[];
    }>;
    getAlbum(albumId: number): Promise<Album>;
    getArtist(artistId: number): Promise<{
        readonly artist: Artist;
        readonly similar: Artist[];
        readonly allSimilar: Artist[];
        readonly albums: Album[];
        readonly alsoAlbums: Album[];
        readonly tracks: Track[];
        readonly playlistIds: {
            readonly uid: number;
            readonly kind: number;
        }[];
        readonly playlists: Playlist[];
        readonly trackIds: number[];
    }>;
    getPlaylist(uid: number | string, kind: number): Promise<{
        playlist: Playlist;
    }>;
    getTrackDownloadLink(trackId: number): Promise<string>;
    getCoverDownloadLink(coverUri: string, size: number): Promise<string>;
    getLocale(): string;
}
