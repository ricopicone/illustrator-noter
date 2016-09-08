on run argv
     tell application "Adobe Illustrator"
          -- 'do javascript' runs any arbitrary JS.
          -- We're using the #include feature to run another
          -- file. (That's an Adobe extension to JS.)
          --
          -- You have to pass a full, absolute path to #include.
          --
          -- The documentation alleges that 'do javascript'
          -- can be passed an AppleScript file object, but
          -- I wasn't able to get that to work.
          -- tell application "Finder"
          --    set current_path to container of (path to me) as alias
          -- end tell
          set js to "#include " & item 1 of argv & "/mySaveAsArchivePDFs.jsx" & return
          do javascript js
     end tell
end run