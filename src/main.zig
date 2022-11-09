const std = @import("std");
const File = std.fs.File;

// header constants
const HEADER_SIZE = 36;
const AUDIO_FORMAT = 1;
const NUM_CHANNELS = 1;
const SAMPLE_RATE = 44100;
const SUBCHUNK1_SIZE = 16;
const BIT_DEPTH = 8;
const BYTE_SIZE = 8;
const PI = std.math.pi;

// audio parameters
const TIME = 5;
const FREQ = 440.0;

pub fn main() !void {
    const cwd = std.fs.cwd();
    var file = try cwd.createFile("sine.wav", .{});
    defer file.close();

    try writeHeaders(TIME, file.writer());
    try renderSineWave(TIME, file.writer(), FREQ);
}

fn writeHeaders(seconds: u32, file: File.Writer) !void {
    try file.writeAll("RIFF");

    const numsamples: u32 = SAMPLE_RATE * seconds;
    try file.writeIntLittle(u32, HEADER_SIZE + numsamples);

    try file.writeAll("WAVEfmt ");
    try file.writeIntLittle(u32, SUBCHUNK1_SIZE);
    try file.writeIntLittle(u16, AUDIO_FORMAT);
    try file.writeIntLittle(u16, NUM_CHANNELS);
    try file.writeIntLittle(u32, SAMPLE_RATE);
    try file.writeIntLittle(u32, SAMPLE_RATE * NUM_CHANNELS * (BIT_DEPTH / BYTE_SIZE));
    try file.writeIntLittle(u16, (NUM_CHANNELS * (BIT_DEPTH / BYTE_SIZE)));
    try file.writeIntLittle(u16, BIT_DEPTH);

    try file.writeAll("data");
    try file.writeIntLittle(u32, numsamples * NUM_CHANNELS * (BIT_DEPTH / BYTE_SIZE));
}

fn renderSineWave(seconds: u32, file: File.Writer, freq: f64) !void {
    var idx: u32 = 0;
    while (idx < seconds * SAMPLE_RATE) : (idx += 1) {
        const sample = ((@sin((freq * @intToFloat(f64, idx) * (2.0 * PI / @as(comptime_float, SAMPLE_RATE)))) + 1.0) / 2.0) * 255.0;
        try file.writeByte(@floatToInt(u8, sample));
    }
}
