module wikipedia_indexer.subcommands.create.hashset;

package:

struct HashSet(T)
{
private:
    void[0][T] aa;

public:

    this(T t)
    {
        add(t);
    }

    void add(T t)
    {
        aa[t] = [];
    }

    void addAll(typeof(this) other)
    {
        foreach (e; other[])
        {
            add(e);
        }
    }

    bool remove(T t)
    {
        return aa.remove(t);
    }

    void clear()
    {
        aa.clear();
    }

    auto length() const @property
    {
        return aa.length;
    }

    auto opIndex()
    {
        return (cast(const void[0][T]) aa).byKey;
    }

    bool opBinaryRight(string op)(T lhs) if (op == "in")
    {
        return lhs in aa;
    }
}
