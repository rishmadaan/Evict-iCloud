-- Evict local iCloud Drive copies (Sequoia-safe)
set tgt to choose folder with prompt ¬
  "Pick the iCloud-Drive folder whose local copies you want to remove:"
set p to POSIX path of tgt

display dialog "Evict local copies in:" & return & p ¬
  buttons {"Cancel", "Continue"} default button "Continue"

try
    -- use /usr/bin/brctl if present; else fall back to old private path
    set br to "/usr/bin/brctl"
    if (do shell script "test -x " & br & "; echo $?") ≠ "0" then ¬
        set br to "/System/Library/PrivateFrameworks/CloudDocsDaemon.framework/Versions/A/Support/brctl"

    -- one command is enough: brctl evict <directory> is recursive
    do shell script quoted form of br & " evict " & quoted form of p

    display dialog "Done! macOS will free the space in a few seconds." buttons {"OK"}
on error eMsg number eNum
    display alert "Error (" & eNum & "): " & eMsg
end try
