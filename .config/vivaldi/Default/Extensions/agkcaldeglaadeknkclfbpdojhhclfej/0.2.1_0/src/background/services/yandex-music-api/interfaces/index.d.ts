declare enum TrackType {
    MUSIC = "music",
    PODCAST_EPISODE = "podcast-episode"
}
declare enum AlbumMetaType {
    MUSIC = "music",
    PODCAST = "podcast"
}
declare type Label = {
    readonly id: number;
    readonly name: string;
};
declare type Tag = {
    readonly id: number;
    readonly value: string;
};
declare type BaseCover = {
    readonly type: string;
};
declare type FromAlbumCover = BaseCover & {
    readonly type: 'from-album-cover';
    readonly uri: string;
    readonly prefix: string;
};
declare type FromArtistPhotosCover = BaseCover & {
    readonly type: 'from-artist-photos';
    readonly uri: string;
    readonly prefix: string;
};
declare type MosaicCover = BaseCover & {
    readonly type: 'mosaic';
    readonly itemsUri: string[];
    readonly custom: boolean;
};
declare type PicCover = BaseCover & {
    readonly type: 'pic';
    readonly dir: string;
    readonly version: string;
    readonly uri: string;
    readonly custom: boolean;
};
declare type Cover = FromAlbumCover | FromArtistPhotosCover | MosaicCover | PicCover;
declare type ArtistBaseLink = {
    readonly type: string;
    readonly title: string;
    readonly href: string;
};
declare type ArtistOfficialLink = ArtistBaseLink & {
    readonly type: 'official';
};
declare type ArtistSocialLink = ArtistBaseLink & {
    readonly type: 'social';
    readonly socialNetwork: string;
};
declare type ArtistLink = ArtistOfficialLink | ArtistSocialLink;
export declare type Track = {
    readonly id: number;
    readonly realId: string;
    readonly title: string;
    readonly version?: string;
    readonly major: {
        readonly id: number;
        readonly name: string;
    };
    readonly available: boolean;
    readonly availableForPremiumUsers: boolean;
    readonly availableFullWithoutPermission: boolean;
    readonly durationMs: number;
    readonly storageDir: string;
    readonly fileSize: number;
    readonly normalization: {
        readonly gain: number;
        readonly peek: number;
    };
    readonly r128?: {
        i: number;
        tp: number;
    };
    readonly previewDurationMs: number;
    readonly artists: Pick<Artist, 'id' | 'name' | 'various' | 'composer' | 'cover'>[];
    readonly albums: ({
        readonly trackPosition: {
            readonly volume: number;
            readonly index: number;
        };
    } & Album)[];
    readonly coverUri?: string;
    readonly ogImage: string;
    readonly lyricsAvailable: boolean;
    readonly type: TrackType;
    readonly rememberPosition: boolean;
    readonly trackSharingFlag: 'VIDEO_ALLOWED';
    readonly backgroundVideoUri?: string;
    readonly batchId: string;
};
export declare type Album = {
    readonly id: number;
    readonly title: string;
    readonly metaType: AlbumMetaType;
    readonly contentWarning: 'explicit';
    readonly year: number;
    readonly releaseDate: string;
    readonly coverUri: string;
    readonly ogImage: string;
    readonly genre: string;
    readonly trackCount: number;
    readonly likesCount: number;
    readonly recent: boolean;
    readonly veryImportant: boolean;
    readonly artists: Pick<Artist, 'id' | 'name' | 'various' | 'composer' | 'cover'>[];
    readonly labels: Label[];
    readonly available: boolean;
    readonly availableForPremiumUsers: boolean;
    readonly availableForMobile: boolean;
    readonly availablePartially: boolean;
    readonly bests: number[];
    readonly volumes: Track[][];
};
export declare type Playlist = {
    readonly revision: number;
    readonly kind: number;
    readonly title: string;
    readonly description: string;
    readonly descriptionFormatted: string;
    readonly trackCount: number;
    readonly visibility: 'public' | 'private';
    readonly cover: Cover;
    readonly ogImage: string;
    readonly owner: {
        readonly uid: number;
        readonly login: string;
        readonly name: string;
        readonly sex: 'male' | 'female';
        readonly verified: boolean;
        readonly avatarHash: string;
    };
    readonly tracks: Track[];
    readonly trackIds: number[];
    readonly modified: string;
    readonly tags: Tag[];
    readonly likesCount: number;
    readonly duration: number;
    readonly available: boolean;
};
export declare type Artist = {
    readonly id: number;
    readonly name: string;
    readonly various: boolean;
    readonly composer: boolean;
    readonly cover: Cover;
    readonly allCovers: Cover[];
    readonly ogImage: string;
    readonly genres: string[];
    readonly counts: {
        readonly tracks: number;
        readonly directAlbums: number;
        readonly alsoAlbums: number;
        readonly alsoTracks: number;
        readonly similarCount: number;
    };
    readonly likesCount: number;
    readonly available: boolean;
    readonly ratings: {
        readonly week: number;
        readonly month: number;
        readonly day: number;
    };
    readonly links: ArtistLink[];
    readonly ticketsAvailable: boolean;
};
export declare type Lyric = {
    readonly id: number;
    readonly lyrics: string;
    readonly fullLyrics: string;
    readonly hasRights: string;
    readonly textLanguage: string;
    readonly showTranslation: boolean;
};
export interface YandexMusicAPI {
    getLocale(): string;
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
    getPlaylist(uid: number, kind: number): Promise<{
        playlist: Playlist;
    }>;
    getTrackDownloadLink(trackId: number): Promise<string>;
    getCoverDownloadLink(coverUri: string, size: number): Promise<string>;
}
export {};
