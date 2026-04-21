function runcpp
    if test "$PWD" = "/run/media/apple/Alpha/competitiveProgramming/editor"
        g++ -std=c++20 -O2 -Wall -Wextra workspace.cpp -o workspace && ./workspace
    end
end
