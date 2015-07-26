import std.stdio;
import std.file;
import std.string;
import std.array;
import std.format;
import std.algorithm;
import std.range;
import std.path;
import std.conv;

struct Character
{
    ubyte s;
    dchar u;
}

struct CharRange
{
    Character[] mapping;
    uint min;
    uint max;
}

struct IndentWriter
{
    int indent;

    auto ref writeln(T...)(T args)
    {
        std.stdio.write(' '.repeat(4 * indent));
        std.stdio.writeln(args);
        return this;
    }

    auto ref writefln(T...)(T args)
    {
        std.stdio.write(' '.repeat(4 * indent));
        std.stdio.writefln(args);
        return this;
    }

    alias indent this;
}

void main(string[] args)
{
    if(args.length < 2) assert(0, "Je nutné zadat soubor");

    auto text = cast(string)read(args[1]);

    // načtení mapy znaků
    auto chars = Appender!(Character[])();
    foreach(line; text.lineSplitter)
    {
        ubyte s;
        uint u;
        if(line.length == 0 || line[0] == '#') continue;
        s = to!ubyte(line[2..4], 16);
        if(line[6] == 'x') u = to!uint(line[7..11], 16);
        else u = '\uFFFD';

        //writefln("0x%02X -> 0x%04X", s, u);
        chars.put(Character(s, u));
    }

    IndentWriter wr;

    auto encName = args[1].stripExtension().baseName;
    auto encTypeName = encName.filter!(a=>a != '-' && a != '_').to!string.capitalize;
    wr.writeln("//=============================================================================");
    wr.writefln("//          %s", encName);
    wr.writeln("//=============================================================================");
    wr.writeln();
    wr.writefln("/** Defines a %s-encoded character. */", encName);
    wr.writefln("enum %sChar : ubyte { init }", encTypeName);
    wr.writeln("/**");
    wr.writefln("Defines an %s-encoded string (as an array of $(D", encTypeName);
    wr.writefln("immutable(%sChar))).", encTypeName);
    wr.writeln("*/");
    wr.writefln("alias %sString = immutable(%sChar)[];", encTypeName, encTypeName);
    wr.writeln();
    wr.writefln("template EncoderInstance(CharType : %sChar)", encTypeName);
    wr.writeln("{")++;

    wr.writefln("alias E = %sChar", encTypeName);
    wr.writefln("alias EString = %sString;", encTypeName);
    wr.writeln();

    wr.writeln("@property string encodingName()");
    wr.writeln("{")++;
    wr.writefln("return \"%s\";", encName.toLower)--;
    wr.writeln("}");



    wr.writeln();
    wr.writeln("mixin EncoderFunctions;")--;
    wr.writeln("}");

//     auto res = chars.data.find!(a => cast(uint)a.s != a.u).array;
//
//     writefln("Starts with %02x", res[0].s);
//     write("\"");
//     foreach(int i, ch; res)
//     {
//         writef("\\u%04x", ch.u);
//         if(i != 0 && (i + 1)%8 == 0) write("\"~\n\"");
//     }
//     writeln(";");
//
//     writeln;
//     writeln("AA:");
//     writeln("[");
//     auto aa = res.filter!(a=>a.u != '\uFFFD').array;
//     bool nl = true;
//     foreach(int i, ch; aa)
//     {
//         if(nl) { write("\t"); nl = false; }
//         else write(", ");
//
//         writef("'\\u%04x': %#02x", ch.u, ch.s);
//
//         if(i != 0 && (i + 1)%4 == 0 && i+1 < aa.length){  writeln(","); nl = true; }
//     }
//     if(!nl) writeln;
//     writeln("]");
//
//     chars.data.sort!((a,b) => a.u < b.u);
//
//     CharRange[] ranges;
//     CharRange cur;
//     foreach(ch; chars.data.filter!(a=>a.u != '\uFFFD'))
//     {
//         //writefln("%04x - %02x", ch.u, ch.s);
//         if(cur.max + 1 == ch.u)
//         {
//             cur.max = ch.u;
//             if(ch.u != cast(dchar)ch.s) cur.mapping ~= ch;
//         }
//         else if(cur != CharRange.init)
//         {
//             ranges ~= cur;
//             cur = CharRange.init;
//             cur.min = cur.max = ch.u;
//             if(ch.u != cast(dchar)ch.s) cur.mapping ~= ch;
//         }
//     }
//     ranges ~= cur;
//
//     foreach(r; ranges)
//     {
//         writefln("%04x:%04x - %s", r.min, r.max, r.mapping);
//         assert(r.mapping.length == 0 || (r.max - r.min + 1) == r.mapping.length);
//     }
//
//     writefln("Total %s ranges", ranges.length);
//
//     write("if (");
//     foreach(i, r; ranges)
//     {
//         if(i != 0) write(" || ");
//         if(r.min != r.max) writef("(c >= 0x%04X && c <= 0x%04X)", r.min, r.max);
//         else writef("c == 0x%04X", r.min);
//     }
//     writeln(") return true;");
//     writeln("else return false;");
//
//
//     writeln();
//     auto bst = aa.sort!((a,b) => a.u < b.u).toBST;
//     assert(bst.isValidBST!((a,b) => a.u < b.u));
//     assert(bst.length == aa.length);
//     foreach(i, ch; bst)
//     {
//         writef("tuple('\\u%04X', '\\x%02X'), ", ch.u, ch.s);
//         if((i+1)%3 == 0) writeln();
//     }
//     writeln("Length: ", bst.length);
//     writeln();
//
// //    writeln();
// //    aa.sort!((a,b) => a.u < b.u);
// //    foreach(i, ch; aa)
// //    {
// //        writef("'\\u%04X', ", ch.u);
// //        if((i+1)%8 == 0) writeln();
// //    }
// //    writeln();
// //    writeln();
//
//     writefln("Valid chars: %('\\u%04X', %)'", chars.data.filter!(a=>a.u != '\uFFFD').map!(a=>a.u));
//     writeln();
//     writefln("Invalid chars: %('\\%04X', %)'", chars.data.filter!(a=>a.u == '\uFFFD').map!(a=>a.u));
}

auto toBST(R)(R input) 
    if (isRandomAccessRange!R)
{
    auto getMid(size_t start, size_t end)
    {
        import std.math;
        auto n = end - start + 1; //počet prvků
        auto h = cast(size_t)ceil(log2(n + 1)); //výška stromu
        auto p = pow(2, h - 1);

        auto m = n/2;
        if(m == p - 1) return start + m;
        return start + min(p - 1, n - p/2);
    }

    void fillBST(ref ElementType!R[] res, size_t start, size_t end, size_t idx)
    {
        if(start > end || end == size_t.max) return;

        auto mid = getMid(start, end);

        //writefln("S: %s, E: %s, IDX: %s, MID: %s", start, end, idx, mid);
        auto i = input[mid];
        res[idx] = i;

        //writefln("VAL: %s", input[mid]);

        fillBST(res, start, mid - 1, 2 * idx + 1);
        fillBST(res, mid + 1, end, 2 * idx + 2);
    }

    ElementType!R[] res;
    res.length = input.length;

    fillBST(res, 0, input.length - 1, 0);
    return res;
}

bool isValidBST(alias pred = "a<b", R)(R input) 
    if (isRandomAccessRange!R)
{
    import std.functional;

    foreach(i; 0..input.length)
    {
        auto left = 2*i+1;
        auto right = 2*i+2;
        if(left < input.length && !binaryFun!pred(input[left], input[i])) return false;
        if(right < input.length && !binaryFun!pred(input[i], input[right])) return false;
    }
    return true;
}

unittest
{
    auto a = [1];
    auto b = a.toBST;
    writefln("%s\n%s\n", a, b);
    assert(b == [1]);
    assert(b.isValidBST);

    a = [1, 2];
    b = a.toBST;
    writefln("%s\n%s\n", a, b);
    assert(b == [2, 1]);
    assert(b.isValidBST);

    a = [1, 2, 3];
    b = a.toBST;
    writefln("%s\n%s\n", a, b);
    assert(b == [2, 1, 3]);
    assert(b.isValidBST);

    a = [1, 2, 3, 4];
    b = a.toBST;
    writefln("%s\n%s\n", a, b);
    assert(b == [3, 2, 4, 1]);
    assert(b.isValidBST);

    a = [1, 2, 3, 4, 5];
    b = a.toBST;
    writefln("%s\n%s\n", a, b);
    assert(b == [4, 2, 5, 1, 3]);
    assert(b.isValidBST);

    a = [1, 2, 3, 4, 5, 6];
    b = a.toBST;
    writefln("%s\n%s\n", a, b);
    assert(b == [4, 2, 6, 1, 3, 5]);
    assert(b.isValidBST);

    a = [1, 2, 3, 4, 5, 6, 7];
    b = a.toBST;
    writefln("%s\n%s\n", a, b);
    assert(b == [4, 2, 6, 1, 3, 5, 7]);
    assert(b.isValidBST);
}