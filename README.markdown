This application creates dependency graphs of Java code.

# How to use

## Generate dependency file
Use [Dependency Finder][depfind], load the JAR in question, then
export the XML dependency information.

## Run the graph creator
```
ruby java_dependency_graph.rb -o my-graphs/ input-graph.xml
```

## View the results
A few files will be created in the output directory. Most interesting
are the graphs, but there is also a simple text summary available.

# More advanced usage
## Only focus on interesting items

Unless you have a very small example, the graphs will probably be too
cluttered to make anything out. You can supply a regex to only include
interesting information. View the application help for more
information about `--interesting-items`.

## Show classes, not just packages
Once you have narrowed down the output to something interesting, you
might wish to add more detail. You can show information about
individual classes instead of packages by using the
`--no-strip-classes` option.

## Skip output formats
If you only care about particular types of output, you can turn off
the ones you dont need. View the application help for the options
`--no-output-*`.

## Highlight interfaces
If you are looking at classes instead of packages, you may want to
distinguish between concrete classes and interfaces. You can use the
`--interface-file` option to do so.

### Generate interface file
This is a nasty hack... but it works. Grep your source information to
find all of your interfaces:

```
git grep 'public interface' src/main/java/ | cut -d: -f1 |
    sort | uniq | sed -e 's@/@.@g' -e 's@.java@@g'
```

# Notes
* Could directly parse the JAR / class file ourselves, which should
  give us access to the interface information directly. This would
  remove the dependency on running an external program as well.

[depfind]: http://depfind.sourceforge.net/