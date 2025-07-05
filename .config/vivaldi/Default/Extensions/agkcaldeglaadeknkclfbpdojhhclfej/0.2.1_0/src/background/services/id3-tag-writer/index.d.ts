/// <reference types="node" />
import ID3Writer from 'browser-id3-writer';
import { ISO6391ToISO6392Converter } from './iso6391-to-iso6392';
export declare class TrackID3TagWriter {
    protected songBuffer_: Buffer;
    protected id3Writer_: ID3Writer;
    protected languageConverter_: ISO6391ToISO6392Converter;
    constructor(songBuffer: Buffer);
    setTitle(title: string): this;
    setVersion(version: string): this;
    setLanguage(language: string): this;
    setDuration(duration: number): this;
    setType(type: string): this;
    setGenre(genre: string): this;
    setLabel(label: string): this;
    setLyric(lyrics: string, description: string, language?: string): this;
    setCover(data: Buffer, description: string): this;
    setArtists(artists: string[]): this;
    setAlbum(album: {
        title?: string;
        artist?: string;
        year?: number;
    }): this;
    setPositionInAlbum(position: number): this;
    setVolume(volume: number): this;
    getTrack(): Buffer;
    getUrl(): string;
    revokeUrl(): void;
}
