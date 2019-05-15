/*
* Copyright (c) 2018 Murilo Venturoso
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Murilo Venturoso <muriloventuroso@gmail.com>
*/

using Gee;

namespace EasySSH {
    public class Bookmark : Object {

        /* Fields */
        public string name {get; set;}
        public string command {get; set;}

    }


    public class BookmarkManager : Object {
        private ArrayList<Bookmark> bookmarks;

        construct {
            bookmarks = new ArrayList<Bookmark> ();
        }

        public int get_length() {
            int i = 0;
            foreach (Bookmark bookmark in bookmarks) {
                if(bookmark != null){
                    i += 1;
                }
            }
            return i;
        }

        public void update_bookmark(string bookmark_name, Bookmark bookmark) {
            for(int a = 0; a < get_length(); a++) {
                if(bookmarks[a].name == bookmark_name) {
                    bookmarks[a] = bookmark;
                    break;
                }
            }
        }

        public void add_bookmark(Bookmark bookmark) {
            bookmarks.add(bookmark);
        }

        public ArrayList<Bookmark> get_bookmarks() {
            return bookmarks;
        }

        public void remove_bookmark(string bookmark_name) {
            int i = -1;
            for(int a = 0; a < get_length(); a++) {
                if(bookmarks[a].name == bookmark_name) {
                    i = a;
                    break;
                }
            }
            if(i != -1) {
                bookmarks.remove_at(i);
            }
        }


        public Bookmark? get_bookmark_by_name(string name) {
            Bookmark? get_bookmark = null;
            for(int a = 0; a < get_length(); a++) {
                if(bookmarks[a].name == name) {
                    get_bookmark = bookmarks[a];
                    break;
                }
            }
            return get_bookmark;
        }

        public Bookmark? get_bookmark(Bookmark bookmark) {
            Bookmark? get_bookmark = null;
            for(int a = 0; a < get_length(); a++) {
                if(bookmarks[a] == bookmark) {
                    get_bookmark = bookmarks[a];
                    break;
                }
            }
            return get_bookmark;
        }

        public bool exist_bookmark_name(string name) {
            var n_bookmark = get_bookmark_by_name(name);
            if(n_bookmark != null) {
                return true;
            }
            return false;
        }


    }
}