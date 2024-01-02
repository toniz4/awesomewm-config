(local gears (require :gears))
(local beautiful (require :beautiful))
(beautiful.init (.. (gears.filesystem.get_configuration_dir) :theme.lua))

(local tabbed (require "lib.tabbed"))
;; (local bling (require "bling"))

(local awful (require :awful))
(local menubar (require :menubar))
(local naughty (require :naughty))
(local utils (require :utils))
(local wibox (require :wibox))
(local widgets (require :widgets))

(require :awful.autofocus)

(local volume utils.volume)
(local movements (require "utils.movements"))

;; Setup

(local mod-key :Mod4)
(local terminal "xst")
(tabbed.spawn_in_tab)

;; Notifications

(set naughty.config.defaults.border_width beautiful.notification_border_width)
;; cu-anan

(fn naughty.config.notify_callback [args]
  (let [c client.focus]
    (when c
      (if (and c.fullscreen (not= args.timeout 0))
          (do
            (naughty.suspend) nil)
          (do
            (naughty.resume) args)))))

;; Error handling

(when awesome.startup_errors
  (naughty.notify {:preset naughty.config.presets.critical
                   :text awesome.startup_errors
                   :title "Oops, there were errors during startup!"}))

(do
  (var in-error false)
  (awesome.connect_signal "debug::error"
                          (fn [err]
                            (when (not in-error)
                              (set in-error true)
                              (naughty.notify {:preset naughty.config.presets.critical
                                               :text (tostring err)
                                               :title "Oops, an error happened!"})
                              (set in-error false)))))

;; cu
;; Functions

(fn assoc [table key value]
  (let [tbl table]
    (tset tbl key value)
    tbl))

(fn debug-notify [value]
  (naughty.notify {:text (tostring value)
                   :title "--DEBUG--"}))

(fn swap-master [c]
  (if (= c (awful.client.getmaster))
      (do (awful.client.swap.byidx 1)
          (awful.client.focus.byidx (- 1)))
      (c:swap (awful.client.getmaster))))

(fn client-menu []
  (global clients {})
  (each [i c (pairs (client.get))]
    (when (not (awful.rules.match_any c {:instance [:scratch :umpv :music]}))
      (tset clients i [c.name
                       (fn [] (c.first_tag:view_only) (set client.focus c))
                       c.icon])))
  (: (awful.menu clients) :show))

;; Menubar

(set menubar.utils.terminal terminal)

;; Layouts

(set awful.layout.layouts [awful.layout.suit.tile
                           awful.layout.suit.tile.bottom
                           awful.layout.suit.fair
                           awful.layout.suit.max
                           awful.layout.suit.max.fullscreen
                           awful.layout.suit.magnifier
                           awful.layout.suit.floating])
;; Buttons

(root.buttons (gears.table.join
               ;; (awful.button {} 3 (fn [] (debug-notify "cuzin?")))
               (awful.button {} 4 awful.tag.viewnext)
               (awful.button {} 5 awful.tag.viewprev)))

;; Key bindings

(var globalkeys
     (gears.table.join
      (awful.key {} :XF86AudioRaiseVolume
                 (fn []
                   (volume.inc 5)
                   (widgets.volume:update)))
      (awful.key {} :XF86AudioLowerVolume
                 (fn []
                   ;; (widgets.volume:update)

                   (naughty.notify {:preset naughty.config.presets.critical
                                    :text "anus?"
                                    :title "Oops, there were errors during startup!"})
                   ;; (naughty.notify {:title "cu"})
                   ;; (volume.dec 5)
                   ;; (widgets.volume:update)
                   ;; (update-volume-status)
                   ))
      (awful.key {} :XF86AudioMute
                 (fn []
                   (volume.mute 5)
                   ;; (utils.wpctl.toggle_mute 5)
                   ;; (update-volume-status)
                   ))
      (awful.key {} :XF86MonBrightnessDown
                 (fn [] (awful.spawn "light -U 10")))
      (awful.key {} :XF86MonBrightnessUp
                 (fn [] (awful.spawn "light -A 10")))
      (awful.key {} :XF86Launch1
                 (fn [] (awful.menu.client_list)))
      (awful.key {} :Print
                 (fn [] (awful.spawn "shot full"))
                 {:description "screen shot"
                  :group :hotkeys})
      (awful.key [:Shift] :Print
                 (fn [] (awful.spawn "shot sel"))
                 {:description "screen shot"
                  :group :hotkeys})
      (awful.key [mod-key] :s
                 (fn [] (awful.spawn :google-chrome-stable))
                 {:description "open browser"
                  :group :hotkeys})
      (awful.key [mod-key :Shift] :s
                 (fn []
                   (tabbed.create)
                   ;; (tabbed.pick_by_direction "down")
                   ;; (bling.module.tabbed.pick_by_direction "down")
                   )
                 {:description "open browser"
                  :group :hotkeys})
      (awful.key [mod-key] :e
                 (fn [] (awful.spawn "emacsclient -c")))
      (awful.key [mod-key :Shift] :t
                 (fn [] (awful.spawn :telegram-desktop))
                 {:description "toggle keep on top"
                  :group :client})
      (awful.key [mod-key] :o
                 (fn []
                   (utils.scratch.toggle (.. terminal
                                             " --class scratch")
                                         {:instance :scratch}
                                         false))
                 {:description "open terminal scratchpad"
                  :group :awesome})
      (awful.key [mod-key] :i
                 (fn []
                   (utils.scratch.toggle "emacsclient -c --frame-parameters='(quote (name . \"music\") (width . 250) (height . 80))' -e '(open-emms-window)'"
                                         {:instance :music}
                                         false))
                 {:description "open terminal scratchpad"
                  :group :awesome})
      (awful.key [mod-key] :u movements.pop
                 {:description "open umpv scratchpad"
                  :group :awesome})
      (awful.key [mod-key] :Left awful.tag.viewprev
                 {:description "view previous" :group :tag})
      (awful.key [mod-key] :Right awful.tag.viewnext
                 {:description "view next" :group :tag})
      (awful.key [mod-key] :Escape
                 movements.exit_mode
                 {:description "Exit mode" :group :tag})
      (awful.key [mod-key] :j
                 (fn []
                   (movements.focus 1))
                 {:description "focus next by index"
                  :group :client})
      (awful.key [mod-key] :k
                 (fn []
                   (movements.focus -1))
                 {:description "focus previous by index"
                  :group :client})
      (awful.key [mod-key :Shift] :j
                 (fn []
                   (movements.swap 1)
                   ;; (awful.client.swap.byidx 1)
                   ))
      (awful.key [mod-key :Shift] :k
                 (fn []
                   (movements.swap -1))
                 {:description "swap with previous client by index"
                  :group :client})
      (awful.key [mod-key :Control] :j
                 (fn [] (awful.screen.focus_relative 1))
                 {:description "focus the next screen"
                  :group :screen})
      (awful.key [mod-key :Control] :k
                 (fn [] (awful.screen.focus_relative (- 1)))
                 {:description "focus the previous screen"
                  :group :screen})
      (awful.key [mod-key :Control :Shift] :j
                 (fn []
                   (when client.focus
                     (client.focus:move_to_screen 1)))
                 {:description "focus the next screen"
                  :group :screen})
      (awful.key [mod-key :Control :Shift] :k
                 (fn []
                   (when client.focus
                     (client.focus:move_to_screen (- 1))))
                 {:description "focus the previous screen"
                  :group :screen})
      (awful.key [mod-key :Shift] :u
                 awful.client.urgent.jumpto
                 {:description "jump to urgent client"
                  :group :client})
      (awful.key [mod-key] :Tab
                 (fn []
                   (awful.client.focus.history.previous)
                   (when client.focus (client.focus:raise)))
                 {:description "go back" :group :client})
      (awful.key [mod-key] :Return
                 (fn [] (awful.spawn terminal))
                 {:description "open a terminal"
                  :group :launcher})
      (awful.key [mod-key :Control] :r awesome.restart
                 {:description "reload awesome"
                  :group :awesome})
      (awful.key [mod-key :Shift] :q awesome.quit
                 {:description "quit awesome"
                  :group :awesome})
      (awful.key [mod-key] :l
                 (fn []
                   (movements.right))
                 {:description "increase master width factor"
                  :group :layout})
      (awful.key [mod-key] :h
                 (fn []
                   (movements.left))
                 {:description "decrease master width factor"
                  :group :layout})
      (awful.key [mod-key :Shift] :h
                 (fn [] (awful.tag.incnmaster 1 nil true))
                 {:description "increase the number of master clients"
                  :group :layout})
      (awful.key [mod-key :Shift] :l
                 (fn []
                   (awful.tag.incnmaster (- 1) nil true))
                 {:description "decrease the number of master clients"
                  :group :layout})
      (awful.key [mod-key :Control] :h
                 (fn []
                   ;; (bling.module.tabbed.iter 1)
                   )
                 {:description "increase the number of columns"
                  :group :layout})
      (awful.key [mod-key :Control] :l
                 (fn []
                   ;; (bling.module.tabbed.iter -1)
                   )
                 {:description "decrease the number of columns"
                  :group :layout})
      (awful.key [mod-key] :space
                 (fn [] (awful.layout.inc 1))
                 {:description "select next"
                  :group :layout})
      (awful.key [mod-key :Shift] :space
                 (fn [] (awful.layout.inc (- 1)))
                 {:description "select previous"
                  :group :layout})
      (awful.key [mod-key :Control] :n
                 (fn []
                   (let [c (awful.client.restore)]
                     (when c
                       (c:emit_signal "request::activate"
                                      :key.unminimize
                                      {:raise true}))))
                 {:description "restore minimized"
                  :group :client})
      (awful.key [mod-key] :r
                 (fn []
                   (: (. (awful.screen.focused)
                         :mypromptbox)
                      :run))
                 {:description "run prompt"
                  :group :launcher})
      (awful.key [mod-key :Shift] :r
                 (fn []
                   (movements.set_mode :resize)
                   ;; (client-menu)
                   )
                 {:description "run prompt"
                  :group :launcher})
      (awful.key [mod-key] :x
                 (fn [] (os.execute "sleep 1")
                   (awful.spawn "xset dpms force suspend"))
                 {:description "Lock screen"
                  :group :awesome})
      (awful.key [mod-key] :p (fn [] (menubar.show))
                 {:description "show the menubar"
                  :group :launcher})))

(for [i 1 9]
  (set globalkeys
       (gears.table.join
        globalkeys
        (awful.key [mod-key] (.. "#" (+ i 9))
               (fn []
                 (let [screen (awful.screen.focused)
                       tag (. screen.tags i)]
                   (when tag (tag:view_only))))
               {:description (.. "view tag #" i)
                :group :tag})
    (awful.key [mod-key :Control] (.. "#" (+ i 9))
               (fn []
                 (let [screen (awful.screen.focused)
                       tag (. screen.tags i)]
                   (when tag (awful.tag.viewtoggle tag))))
               {:description (.. "toggle tag #" i)
                :group :tag})
    (awful.key [mod-key :Shift] (.. "#" (+ i 9))
               (fn []
                 (when client.focus
                   (local tag
                          (. client.focus.screen.tags i))
                   (when tag
                     (client.focus:move_to_tag tag))))
               {:description (.. "move focused client to tag #"
                                 i)
                :group :tag})
    (awful.key [mod-key :Control :Shift]
               (.. "#" (+ i 9))
               (fn []
                 (when client.focus
                   (local tag
                          (. client.focus.screen.tags i))
                   (when tag
                     (client.focus:toggle_tag tag))))
               {:description (.. "toggle focused client on tag #"
                                 i)
                :group :tag}))))

(root.keys globalkeys)

;; Screen

(fn set-wallpaper []
  (when (gears.filesystem.file_readable beautiful.wallpaper)
    (let [wallpaper (gears.surface.load_uncached beautiful.wallpaper)
          (w h) (gears.surface.get_size wallpaper)]
      (if (or (< w 500) (< h 500))
          (gears.wallpaper.tiled wallpaper)
          (gears.wallpaper.maximized wallpaper)))))

(local taglist-buttons
       (gears.table.join
        (awful.button [] 1
                      (fn [t]
                        (t:view_only)))
        (awful.button [mod-key] 1
                      (fn [t]
                        (when client.focus
                          (client.focus:move_to_tag t))))
        (awful.button [] 3
                      awful.tag.viewtoggle)
        (awful.button [mod-key] 3
                      (fn [t]
                        (when client.focus
                          (client.focus:toggle_tag t))))))

(local tasklist-buttons
       (gears.table.join (awful.button {} 1
                                       (fn [c]
                                         (if (= c client.focus)
                                             (set c.minimized true)
                                             (c:emit_signal "request::activate"
                                                            :tasklist
                                                            {:raise true}))))
                         (awful.button {} 3
                                       (fn []
                                         (awful.menu.client_list {:theme {:width 250}})))))

(awful.screen.connect_for_each_screen
 (fn [s]
   (awful.tag.add :1
                  {:layout awful.layout.suit.max
                   :layouts awful.layout.layouts
                   :screen s
                   :selected true})
   (for [tag 2 10]
     (awful.tag.add (tostring tag)
                    {:layout (. awful.layout.layouts
                                1)
                     :layouts awful.layout.layouts
                     :screen s}))
   (set s.mypromptbox
        (awful.widget.prompt))
   ;; (set s.mylayoutbox (awful.widget.layoutbox s))
   (set s.mylayoutbox (widgets.layoutbox s))
   (s.mylayoutbox:buttons (gears.table.join (awful.button {} 1
                                                          (fn []
                                                            (awful.layout.inc 1)))
                                            (awful.button {} 3
                                                          (fn []
                                                            (awful.layout.inc (- 1))))
                                            (awful.button {} 4
                                                          (fn []
                                                            (awful.layout.inc 1)))
                                            (awful.button {} 5
                                                          (fn []
                                                            (awful.layout.inc (- 1))))))
   (set s.mytaglist
        (awful.widget.taglist {:buttons taglist-buttons
                               :filter awful.widget.taglist.filter.noempty
                               :screen s}))
   (set s.mytasklist
        (widgets.tasklist s)
        ;; (awful.widget.tasklist {:buttons tasklist-buttons
        ;;                         :filter awful.widget.tasklist.filter.currenttags
        ;;                         :layout {:layout wibox.layout.flex.horizontal}
        ;;                         :screen s
        ;;                         :widget_template {1 {1 {1 {1 {:id :icon_role
        ;;                                                       :widget wibox.widget.imagebox}
        ;;                                                    :bottom 5
        ;;                                                    :right 10
        ;;                                                    :top 5
        ;;                                                    :widget wibox.container.margin}
        ;;                                                 2 {:id :text_role
        ;;                                                    :widget wibox.widget.textbox}
        ;;                                                 :layout wibox.layout.fixed.horizontal}
        ;;                                              :widget wibox.container.place}
        ;;                                           :id :background_role
        ;;                                           :widget wibox.container.background}})
        )
   (when (= s screen.primary)
     (set-wallpaper)
     (set s.mywibox
          (awful.wibar {:height 40
                        :position :bottom
                        :screen s}))
     (s.mywibox:setup
      (let [left (-> [s.mytaglist
                      widgets.mode
                      s.mypromptbox]
                     (assoc :layout wibox.layout.fixed.horizontal))
            middle (-> [{:widget s.mytasklist}]
                       (assoc :right 5)
                       (assoc :widget wibox.container.margin 5))
            right (-> [widgets.mpd
                       widgets.volume
                       widgets.memory
                       widgets.gpu.temp
                       widgets.cpu.temp
                       widgets.cpu.usage
                       widgets.date
                       s.mylayoutbox]
                      (assoc :layout wibox.layout.fixed.horizontal)
                      (assoc :spacing 10))]
        (-> [left middle right]
            (assoc :layout wibox.layout.align.horizontal)))))))

;; Client keys

(global clientkeys
        (gears.table.join
         (awful.key [mod-key] :f
                    (fn [c]
                      (set c.fullscreen (not c.fullscreen))
                      (c:raise))
                    {:description "toggle fullscreen"
                     :group :client})
         (awful.key [mod-key] :w
                    (fn [c]
                      (c:kill))
                    {:description :close :group :client})
         (awful.key [mod-key :Control] :space
                    awful.client.floating.toggle
                    {:description "toggle floating"
                     :group :client})
         (awful.key [mod-key :Shift] :Return
                    (fn [c]
                      (swap-master c))
                    {:description "move to master"
                     :group :client})
         (awful.key [mod-key] :t
                    (fn [c]
                      (set c.ontop (not c.ontop)))
                    {:description "toggle keep on top"
                     :group :client})
         (awful.key [mod-key] :n
                    (fn [c]
                      (set c.minimized true))
                    {:description :minimize :group :client})
         (awful.key [mod-key] :m
                    (fn [c]
                      (set c.maximized (not c.maximized))
                      (c:raise))
                    {:description "(un)maximize"
                     :group :client})
         (awful.key [mod-key :Control] :m
                    (fn [c]
                      (set c.maximized_vertical
                           (not c.maximized_vertical))
                      (c:raise))
                    {:description "(un)maximize vertically"
                     :group :client})
         (awful.key [mod-key :Shift] :m
                    (fn [c]
                      (set c.maximized_horizontal
                           (not c.maximized_horizontal))
                      (c:raise))
                    {:description "(un)maximize horizontally"
                     :group :client})))

(local clientbuttons
       (gears.table.join
        (awful.button {} 1
                      (fn [c]
                        (c:emit_signal "request::activate"
                                       :mouse_click
                                       {:raise true})))
        (awful.button [mod-key] 1
                      (fn [c]
                        (c:emit_signal "request::activate"
                                       :mouse_click
                                       {:raise true})
                        (awful.mouse.client.move c)))
        (awful.button [mod-key] 3
                      (fn [c]
                        (c:emit_signal "request::activate"
                                       :mouse_click
                                       {:raise true})
                        (awful.mouse.client.resize c)))))

;; Rules

(fn center-float [client]
  (awful.placement.centered client nil)
  (set client.ontop true))

(set awful.rules.rules
     [{:properties {:border_color beautiful.border_normal
                    :border_width beautiful.border_width
                    :buttons clientbuttons
                    :focus awful.client.focus.filter
                    :keys clientkeys
                    :placement (+ awful.placement.no_overlap
                                  awful.placement.no_offscreen)
                    :raise false
                    :screen awful.screen.preferred
                    :size_hints_honor false}
       :rule {}}
      {:callback center-float
       :properties {:floating true}
       :rule_any {:class [:Pavucontrol]
                  :instance [:pinentry]
                  :name ["Event Tester"]
                  :role [:AlarmWindow :ConfigManager]}}
      {:callback center-float
       :properties {:floating true :raise true}
       :rule_any {:instance [:scratch :umpv :music]}}
      {:properties {:height 750 :width 1500}
       :rule_any {:instance [:scratch]}}
      ;; {:callback center-float
      ;;  :rule_any {:floating true}}
      ])

;; Signals

(fn append-client [c next-client]
  (let [cls (awful.client.tiled)]
    (each [_ v (pairs cls) &until (= v next-client)]
      (c:swap v))
    (c:swap next-client)))

(client.connect_signal
 :manage
 (fn [c]
   (when (not awesome.startup)
     (let [last (awful.client.focus.history.get c.screen 1)]
       (when last
         (if (> (length (awful.client.tiled)) 2)
             (append-client c last)
             (awful.client.setslave c)))))
   (when (and (and awesome.startup (not c.size_hints.user_position))
              (not c.size_hints.program_position))
     (awful.placement.no_offscreen c))))

(client.connect_signal "mouse::enter"
                       (fn [c]
                         (c:emit_signal "request::activate"
                                        :mouse_enter
                                        {:raise false})))
(client.connect_signal
 :focus
 (fn [c]
   (set c.border_color beautiful.border_focus)))

(client.connect_signal
 :unfocus
 (fn [c]
   (set c.border_color beautiful.border_normal)))

(screen.connect_signal
 :arrange
 (fn [s]
   (let [max (= s.selected_tag.layout.name :max)
         floating (= s.selected_tag.layout.name :floating)
         only-one (= (length s.tiled_clients) 1)]
     (each [_ c (pairs s.clients)]
       (if (or (and (and (not floating) (or max only-one))
                    (not c.floating))
               c.maximized)
           (set c.border_width 0)
           (set c.border_width beautiful.border_width))))))
