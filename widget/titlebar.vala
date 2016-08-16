/* -*- Mode: Vala; indent-tabs-mode: nil; tab-width: 4 -*-
 * -*- coding: utf-8 -*-
 *
 * Copyright (C) 2011 ~ 2016 Deepin, Inc.
 *               2011 ~ 2016 Wang Yong
 *
 * Author:     Wang Yong <wangyong@deepin.com>
 * Maintainer: Wang Yong <wangyong@deepin.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */ 

using Gtk;
using Widgets;

namespace Widgets {
    public class Titlebar : Gtk.Overlay {
        public Box max_toggle_box;
        
        public ImageButton close_button;
        
        public Widgets.WindowEventArea event_area;
        
        public Titlebar() {
            close_button = new ImageButton("titlebar_close");
            close_button.margin_top = 3;
            close_button.margin_right = 3;
            close_button.set_halign(Gtk.Align.END);
            
            Box box = new Box(Gtk.Orientation.HORIZONTAL, 0);
            box.pack_start(close_button, true, true, 0);
            
            event_area = new Widgets.WindowEventArea(this);
            event_area.margin_end = 27;

            add(box);
            add_overlay(event_area);
            
            set_size_request(-1, Constant.TITLEBAR_HEIGHT);
        }
    }
}