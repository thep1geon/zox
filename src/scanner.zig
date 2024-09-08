const std = @import("std");
const zox = @import("zox.zig");

pub const Token = struct {
    pub const Kind = enum {
        lparen,
        rparen,
        lbrace,
        rbrace,
        comma,
        dot,
        minus,
        plus,
        semicolon,
        slash,
        star,

        bang,
        bang_eq,
        eq,
        eq_eq,
        gt,
        gt_eq,
        lt,
        lt_eq,

        ident,
        string,
        number,

        _and,
        _class,
        _else,
        _false,
        _for,
        _fun,
        _if,
        _nil,
        _or,
        _print,
        _return,
        _super,
        _this,
        _true,
        _var,
        _while,

        _error,
    };

    kind: Token.Kind,
    line: u32,
    lexeme: []const u8,

    pub fn init(kind: Token.Kind, tok_line: u32, lexeme: []const u8) Token {
        return .{
            .kind = kind,
            .line = tok_line,
            .lexeme = lexeme,
        };
    }
};

var src: []const u8 = undefined;
var start: u32 = 0;
var current: u32 = 0;
var line: u32 = 1;
var idents = std.StringHashMap(Token.Kind).init(zox.allocator);

pub fn init(_src: []const u8) void {
    src = _src;
    start = 0;
    current = 0;
    line = 1;

    idents.put("class", ._class) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("and", ._and) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("class", ._class) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("else", ._else) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("false", ._false) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("for", ._for) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("fun", ._fun) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("if", ._if) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("nil", ._nil) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("or", ._or) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("print", ._print) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("return", ._return) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("super", ._super) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("this", ._this) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("true", ._true) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("var", ._var) catch @panic("FAILED TO PUT IN HASHMAP");
    idents.put("while", ._while) catch @panic("FAILED TO PUT IN HASHMAP");
}

pub fn deinit() void {
    idents.deinit();
}

pub fn makeToken(kind: Token.Kind) Token {
    return Token{
        .kind = kind,
        .line = line,
        .lexeme = src[start..current],
    };
}

pub fn errorToken(msg: []const u8) Token {
    return Token.init(._error, line, msg);
}

pub fn isAtEnd() bool {
    return current == src.len - 1;
}

fn advance() u8 {
    defer current += 1;
    return src[current];
}

fn peek() u8 {
    return src[current];
}

fn peekNext() u8 {
    if (isAtEnd()) return 0;

    return src[current + 1];
}

fn match(c: u8) bool {
    if (isAtEnd()) return false;

    if (c == peek()) {
        _ = advance();
        return true;
    }

    return false;
}

fn skipWhitespace() void {
    while (true) {
        if (isAtEnd()) return;
        const c = peek();

        switch (c) {
            ' ' => _ = advance(),
            '\r' => _ = advance(),
            '\t' => _ = advance(),
            '\n' => {
                _ = advance();
                line += 1;
            },
            '/' => {
                if (peekNext() == '/') {
                    while (peek() != '\n' and !isAtEnd()) _ = advance();
                } else {
                    return;
                }
            },
            else => return,
        }
    }
}

fn string() Token {
    while (peek() != '"' and (!isAtEnd())) {
        if (peek() == '\n') line += 1;
        _ = advance();
    }

    if (isAtEnd()) return errorToken("Unterminated string.");

    _ = advance();
    return .{
        .line = line,
        .kind = .string,
        .lexeme = src[start + 1 .. current - 1],
    };
}

fn number() Token {
    while (std.ascii.isDigit(peek())) _ = advance();

    if (peek() == '.' and std.ascii.isDigit(peekNext())) {
        _ = advance();

        while (std.ascii.isDigit(peek())) _ = advance();
    }

    return makeToken(.number);
}

fn identType() Token.Kind {
    const lexeme = src[start..current];
    if (idents.get(lexeme)) |keyword| {
        return keyword;
    }

    return .ident;
}

fn ident() Token {
    while (std.ascii.isAlphanumeric(peek())) _ = advance();
    return makeToken(identType());
}

pub fn scanToken() ?Token {
    skipWhitespace();
    start = current;

    if (isAtEnd()) return null;

    const c = advance();

    if (std.ascii.isAlphabetic(c)) return ident();
    if (std.ascii.isDigit(c)) return number();

    switch (c) {
        '(' => return makeToken(.lparen),
        ')' => return makeToken(.rparen),
        '{' => return makeToken(.lbrace),
        '}' => return makeToken(.rbrace),
        ';' => return makeToken(.semicolon),
        ',' => return makeToken(.comma),
        '.' => return makeToken(.dot),
        '-' => return makeToken(.minus),
        '+' => return makeToken(.plus),
        '/' => return makeToken(.slash),
        '*' => return makeToken(.star),
        '!' => return makeToken(if (match('=')) .bang_eq else .bang),
        '=' => return makeToken(if (match('=')) .eq_eq else .eq),
        '<' => return makeToken(if (match('=')) .lt_eq else .lt),
        '>' => return makeToken(if (match('=')) .gt_eq else .gt),
        '"' => return string(),
        else => blk: {
            break :blk;
        },
    }

    return makeToken(.string);
}
