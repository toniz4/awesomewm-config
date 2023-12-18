(local sink "@DEFAULT_AUDIO_SINK@")

(fn wpctl-cmd [command args]
  (os.execute (.. "wpctl " command " " sink " " args)))

(fn inc [n]
  (wpctl-cmd "set-volume" (.. (tostring n) "%+")))

(fn dec [n]
  (wpctl-cmd "set-volume" (.. (tostring n) "%-")))

(fn mute []
  (wpctl-cmd "set-mute" "toggle"))

{: inc
 : dec
 : mute}
