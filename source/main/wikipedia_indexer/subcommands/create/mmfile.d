module wikipedia_indexer.subcommands.create.mmfile;

package:

struct MmFileRange
{
    import std.mmfile : MmFile;

private:
    MmFile mmFile;
    size_t index = 0;
    size_t reverseIndex;

public:
    this(string fileName)
    {
        mmFile = new MmFile(fileName, MmFile.Mode.read, 0, null,
                largestMultipleOfSmallerThan(4096, 1_000_000));
        reverseIndex = mmFile.length;
    }

    immutable(char) front() @property
    in(!empty)
    {
        return mmFile[index];
    }

    immutable(char) back() @property
    in(!empty)
    {
        return mmFile[reverseIndex - 1];
    }

    void popFront()
    in(!empty)
    {
        index++;
    }

    void popBack()
    in(!empty)
    {
        reverseIndex--;
    }

    bool empty() const @property
    {
        return index == reverseIndex;
    }

    MmFileRange save()
    {
        return this;
    }

    size_t length() const @property
    {
        return reverseIndex - index;
    }

    immutable(char) opIndex(size_t i)
    in(i < length)
    {
        return mmFile[index + i];
    }

    alias opDollar = length;

    auto opIndex()
    {
        return this;
    }

    auto opSlice(size_t a, size_t b)
    in(a <= b)
    in(b <= length)
    {
        auto copy = this;
        copy.reverseIndex = copy.index + b;
        copy.index += a;
        return copy;
    }
}

private:

T largestMultipleOfSmallerThan(T)(T a, T b)
{
    return a * (b / a);
}
