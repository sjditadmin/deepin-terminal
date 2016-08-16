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
using Config;
using Cairo;
using XUtils;

namespace Widgets {
    public class BaseWindow : Widgets.ConfigWindow {
        public int window_frame_margin_top = 50;
        public int window_frame_margin_bottom = 60;
        public int window_frame_margin_start = 50;
        public int window_frame_margin_end = 50;
        
        public int window_widget_margin_top = 1;
        public int window_widget_margin_bottom = 2;
        public int window_widget_margin_start = 2;
        public int window_widget_margin_end = 2;
        
        public int window_save_width = 0;
        public int window_save_height = 0;
        
        public int window_width;
        public int window_height;
        
        public BaseWindow() {
            transparent_window();
            init_window();
        }
        
        public void transparent_window() {
            set_app_paintable(true); // set_app_paintable is neccessary step to make window transparent.
            Gdk.Screen screen = Gdk.Screen.get_default();
            set_visual(screen.get_rgba_visual());
        }
        
        public void init_window() {
            set_decorated(false);
            
            window_frame_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            window_widget_box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            
            add(window_frame_box);
            window_frame_box.pack_start(window_widget_box, true, true, 0);
            
            focus_in_event.connect((w) => {
                    update_style();
                    
                    return false;
                });
            
            focus_out_event.connect((w) => {
                    update_style();
                    
                    return false;
                });
            
            configure_event.connect((w) => {
                    int width, height;
                    get_size(out width, out height);
                    
                    if (!window_is_max() && !window_is_fullscreen() && !window_is_tiled()) {
                        window_save_width = width;
                        window_save_height = height;
                    }
                    
                    Cairo.RectangleInt rect;
                    get_window().get_frame_extents(out rect);
                    
                    if (window_is_max() || window_is_fullscreen()) {
                        rect.x = 0;
                        rect.y = 0;
                        rect.width = width;
                        rect.height = height;
                    } else if (window_is_tiled()) {
                        int monitor = screen.get_monitor_at_window(screen.get_active_window());
                        Gdk.Rectangle screen_rect;
                        screen.get_monitor_geometry(monitor, out screen_rect);

                        if (rect.x + rect.width - window_frame_margin_start == screen_rect.width) {
                            rect.x = window_frame_margin_start;
                            rect.y = 0;
                            rect.width = width - window_frame_margin_start;
                            rect.height = height;
                        } else {
                            rect.x = 0;
                            rect.y = 0;
                            rect.width = width - window_frame_margin_end;
                            rect.height = height;
                        }
                    } else {
                        rect.x = window_frame_margin_start;
                        rect.y = window_frame_margin_top;
                        rect.width = width - window_frame_margin_start - window_frame_margin_end;
                        rect.height = height - window_frame_margin_top - window_frame_margin_bottom;
                    }
                    
                    var shape = new Cairo.Region.rectangle(rect);
                    get_window().input_shape_combine_region(shape, 0, 0);
                    
                    queue_draw();
					
					return false;
                });
            
            window_state_event.connect((w, e) => {
                    update_style();
                    
                    if (window_is_fullscreen()) {
                        get_window().set_shadow_width(0, 0, 0, 0);
                                
                        window_frame_box.margin = 0;
                        
                        window_widget_box.margin_top = 1;
                        window_widget_box.margin_bottom = 0;
                        window_widget_box.margin_start = 0;
                        window_widget_box.margin_end = 0;
                    } else if (window_is_max()) {
                        get_window().set_shadow_width(0, 0, 0, 0);
                                
                        window_frame_box.margin = 0;
                        
                        window_widget_box.margin_top = 1;
                        window_widget_box.margin_bottom = 1;
                        window_widget_box.margin_start = 1;
                        window_widget_box.margin_end = 1;
                    } else if (window_is_tiled()) {
                        Cairo.RectangleInt rect;
                        get_window().get_frame_extents(out rect);
                        
                        int monitor = screen.get_monitor_at_window(screen.get_active_window());
                        Gdk.Rectangle screen_rect;
                        screen.get_monitor_geometry(monitor, out screen_rect);
                        
                        int width, height;
                        get_size(out width, out height);

                        if (rect.x + rect.width - window_frame_margin_start == screen_rect.width) {
                            get_window().set_shadow_width(window_frame_margin_start, 0, 0, 0);
                            
                            window_frame_box.margin_left = window_frame_margin_start;
                            window_frame_box.margin_right = 0;
                            window_frame_box.margin_top = 0;
                            window_frame_box.margin_bottom = 0;
                        } else {
                            get_window().set_shadow_width(0, window_frame_margin_end, 0, 0);
                            
                            window_frame_box.margin_left = 0;
                            window_frame_box.margin_right = window_frame_margin_end;
                            window_frame_box.margin_top = 0;
                            window_frame_box.margin_bottom = 0;
                        }
                        
                        window_widget_box.margin_top = 1;
                        window_widget_box.margin_bottom = 1;
                        window_widget_box.margin_start = 1;
                        window_widget_box.margin_end = 1;
                    } else {
                        get_window().set_shadow_width(window_frame_margin_start, window_frame_margin_end, window_frame_margin_top, window_frame_margin_bottom);
                                
                        window_frame_box.margin_top = window_frame_margin_top;
                        window_frame_box.margin_bottom = window_frame_margin_bottom;
                        window_frame_box.margin_start = window_frame_margin_start;
                        window_frame_box.margin_end = window_frame_margin_end;
            
                        window_widget_box.margin_top = 2;
                        window_widget_box.margin_bottom = 2;
                        window_widget_box.margin_start = 2;
                        window_widget_box.margin_end = 2;
                    }
                    
                    return false;
                });
            
            button_press_event.connect((w, e) => {
                    if (get_resizable()) {
                        if (!window_is_max() && !window_is_fullscreen() && !window_is_tiled()) {
                            int window_x, window_y;
                            get_window().get_origin(out window_x, out window_y);
                        
                            int width, height;
                            get_size(out width, out height);
                        
                            var left_side_start = window_x + window_frame_margin_start;
                            var left_side_end = window_x + window_frame_margin_start + Constant.RESPONSE_RADIUS;
                            var right_side_start = window_x + width - window_frame_margin_end - Constant.RESPONSE_RADIUS;
                            var right_side_end = window_x + width - window_frame_margin_end;
                            var top_side_start = window_y + window_frame_margin_top;
                            var top_side_end = window_y + window_frame_margin_top + Constant.RESPONSE_RADIUS;
                            var bottom_side_start = window_y + height - window_frame_margin_bottom - Constant.RESPONSE_RADIUS;
                            var bottom_side_end = window_y + height - window_frame_margin_bottom;
                        
                            int pointer_x, pointer_y;
                            e.device.get_position(null, out pointer_x, out pointer_y);
                                
                            if (e.x_root > left_side_start && e.x_root < left_side_end) {
                                if (e.y_root > top_side_start && e.y_root < top_side_end) {
                                    resize_window(this, pointer_x, pointer_y, (int) e.button, Gdk.CursorType.TOP_LEFT_CORNER);
                                } else if (e.y_root > bottom_side_start && e.y_root < bottom_side_end) {
                                    resize_window(this, pointer_x, pointer_y, (int) e.button, Gdk.CursorType.BOTTOM_LEFT_CORNER);
                                } else {
                                    resize_window(this, pointer_x, pointer_y, (int) e.button, Gdk.CursorType.LEFT_SIDE);
                                }
                            } else if (e.x_root > right_side_start && e.x_root < right_side_end) {
                                if (e.y_root > top_side_start && e.y_root < top_side_end) {
                                    resize_window(this, pointer_x, pointer_y, (int) e.button, Gdk.CursorType.TOP_RIGHT_CORNER);
                                } else if (e.y_root > bottom_side_start && e.y_root < bottom_side_end) {
                                    resize_window(this, pointer_x, pointer_y, (int) e.button, Gdk.CursorType.BOTTOM_RIGHT_CORNER);
                                } else {
                                    resize_window(this, pointer_x, pointer_y, (int) e.button, Gdk.CursorType.RIGHT_SIDE);
                                }
                            } else {
                                if (e.y_root > top_side_start && e.y_root < top_side_end) {
                                    resize_window(this, pointer_x, pointer_y, (int) e.button, Gdk.CursorType.TOP_SIDE);
                                } else if (e.y_root > bottom_side_start && e.y_root < bottom_side_end) {
                                    resize_window(this, pointer_x, pointer_y, (int) e.button, Gdk.CursorType.BOTTOM_SIDE);
                                }
                            }
                        }
                    }
                    
                    return false;
                });
            
            motion_notify_event.connect((w, e) => {
                    if (get_resizable()) {
                        if (!window_is_max() && !window_is_fullscreen() && !window_is_tiled()) {
                            var display = Gdk.Display.get_default();
                        
                            int window_x, window_y;
                            get_window().get_origin(out window_x, out window_y);
                        
                            int width, height;
                            get_size(out width, out height);
                        
                            var left_side_start = window_x + window_frame_margin_start;
                            var left_side_end = window_x + window_frame_margin_start + Constant.RESPONSE_RADIUS;
                            var right_side_start = window_x + width - window_frame_margin_end - Constant.RESPONSE_RADIUS;
                            var right_side_end = window_x + width - window_frame_margin_end;
                            var top_side_start = window_y + window_frame_margin_top;
                            var top_side_end = window_y + window_frame_margin_top + Constant.RESPONSE_RADIUS;
                            var bottom_side_start = window_y + height - window_frame_margin_bottom - Constant.RESPONSE_RADIUS;
                            var bottom_side_end = window_y + height - window_frame_margin_bottom;
                        
                            if (e.x_root > left_side_start && e.x_root < left_side_end) {
                                if (e.y_root > top_side_start && e.y_root < top_side_end) {
                                    get_window().set_cursor(new Gdk.Cursor.for_display(display, Gdk.CursorType.TOP_LEFT_CORNER));
                                } else if (e.y_root > bottom_side_start && e.y_root < bottom_side_end) {
                                    get_window().set_cursor(new Gdk.Cursor.for_display(display, Gdk.CursorType.BOTTOM_LEFT_CORNER));
                                } else {
                                    get_window().set_cursor(new Gdk.Cursor.for_display(display, Gdk.CursorType.LEFT_SIDE));
                                }
                            } else if (e.x_root > right_side_start && e.x_root < right_side_end) {
                                if (e.y_root > top_side_start && e.y_root < top_side_end) {
                                    get_window().set_cursor(new Gdk.Cursor.for_display(display, Gdk.CursorType.TOP_RIGHT_CORNER));
                                } else if (e.y_root > bottom_side_start && e.y_root < bottom_side_end) {
                                    get_window().set_cursor(new Gdk.Cursor.for_display(display, Gdk.CursorType.BOTTOM_RIGHT_CORNER));
                                } else {
                                    get_window().set_cursor(new Gdk.Cursor.for_display(display, Gdk.CursorType.RIGHT_SIDE));
                                }
                            } else {
                                if (e.y_root > top_side_start && e.y_root < top_side_end) {
                                    get_window().set_cursor(new Gdk.Cursor.for_display(display, Gdk.CursorType.TOP_SIDE));
                                } else if (e.y_root > bottom_side_start && e.y_root < bottom_side_end) {
                                    get_window().set_cursor(new Gdk.Cursor.for_display(display, Gdk.CursorType.BOTTOM_SIDE));
                                } else {
                                    get_window().set_cursor(null);
                                }
                            }
                        }
                    }
                    
                    return false;
                });
            
            draw.connect_after((w, cr) => {
                    draw_window_below(cr);
                       
                    draw_window_widgets(cr);

                    draw_window_frame(cr);
                       
                    draw_window_above(cr);
                    
                    return true;
                });
        }
        
        public void update_style() {
            clean_style();
            
            if (is_active) {
                if (!window_is_max() && !window_is_fullscreen() && !window_is_tiled()) {
                    window_frame_box.get_style_context().add_class("window_shadow_active");
                } else {
                    window_frame_box.get_style_context().add_class("window_noradius_shadow_active");
                }
            } else {
                if (!window_is_max() && !window_is_fullscreen() && !window_is_tiled()) {
                    window_frame_box.get_style_context().add_class("window_shadow_inactive");
                } else {
                    window_frame_box.get_style_context().add_class("window_noradius_shadow_inactive");
                }
            }
        }
        
        public void clean_style() {
            window_frame_box.get_style_context().remove_class("window_shadow_inactive");
            window_frame_box.get_style_context().remove_class("window_shadow_active");
            window_frame_box.get_style_context().remove_class("window_noradius_shadow_inactive");
            window_frame_box.get_style_context().remove_class("window_noradius_shadow_active");
        }
        
        public void draw_window_widgets(Cairo.Context cr) {
            Utils.propagate_draw(this, cr);
        }
        
        public void add_widget(Gtk.Widget widget) {
            window_widget_box.pack_start(widget, true, true, 0);
        }

		public void toggle_fullscreen() {
            if (window_is_fullscreen()) {
                unfullscreen();
            } else {
                fullscreen();
            }
        }
        
        public void toggle_max() {
            if (window_is_max()) {
                unmaximize();
            } else {
                maximize();
            }
        }
        
        public virtual void draw_window_frame(Cairo.Context cr) {
            
        }
        
        public virtual void draw_window_below(Cairo.Context cr) {
            
        }
        
        public virtual void draw_window_above(Cairo.Context cr) {
            
        }
        
        public bool window_is_max() {
            return Gdk.WindowState.MAXIMIZED in get_window().get_state();
        }
        
        public bool window_is_tiled() {
            return Gdk.WindowState.TILED in get_window().get_state();
        }
        
        public bool window_is_fullscreen() {
            return Gdk.WindowState.FULLSCREEN in get_window().get_state();
        }
    }
}
