SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

for filename in $( ls *_framed.png ); do
    
    caption=${filename##*-}
    caption=${caption%_*}
    color="#2B3A42"

    echo $caption

    convert "$filename"                  \
        -background $color  \
        -gravity center         \
        -bordercolor $color  \
        -border 50x50        \
        out.png
    convert ./out.png           \
        -pointsize 36           \
        -font /System/Library/Fonts/Avenir\ Next.ttc  \
        -weight 800             \
        -fill white             \
        -background $color  \
         -size 500 \
        -gravity Center         \
        caption:"$caption"     \
        +swap                   \
        -append                 \
        ./out.png
    convert ./out.png             \
        -background $color   \
        -page +0+200            \
        -flatten                \
        out.png
    convert ./out.png                  \
        -background $color   \
        -gravity south         \
        "out/$filename"

done