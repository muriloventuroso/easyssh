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
    public class Host : Object {

        /* Fields */
        public string name {get; set;}
        public string host {get; set;}
        public string port {get; set;}
        public string username {get; set;}
        public string password {get; set;}
        public string group {get; set;}
        public string color {get; set;}
        public string font {get; set;}
        public string tunnels {get; set;}
        public string identity_file {get; set;}
        public string ssh_config {get; set;}
        public string account {get; set;}
        public Granite.Widgets.DynamicNotebook notebook {get; set;}
        public Granite.Widgets.SourceList.Item? item {get; set;}

        construct {
            notebook = new Granite.Widgets.DynamicNotebook();
        }
    }

    public class Group : Object {

        private ArrayList<Host> hosts;
        public string name {get; construct;}
        public Granite.Widgets.SourceList.ExpandableItem category {get; set;}

        public Group (string name) {
            Object (name: name);
        }

        construct {
            hosts = new ArrayList<Host> ();
        }

        public int compare_hosts (Host a, Host b) {
            if(a.name < b.name) {
                return -1;
            } else {
                return 1;
            }
        }

        public void sort_hosts() {
            hosts.sort(compare_hosts);
        }

        public int get_length() {
            int i = 0;
            foreach (Host host in hosts) {
                if(host != null){
                    i += 1;
                }
            }
            return i;
        }

        public void add_host(Host host) {
            hosts.add(host);
        }

        public ArrayList<Host> get_hosts() {
            return hosts;
        }

        public void update_host(string host_name, Host host) {
            for(int a = 0; a < get_length(); a++) {
                if(hosts[a].name == host_name) {
                    hosts[a] = host;
                    break;
                }
            }
        }

        public void remove_host(string host_name) {
            int i = -1;
            for(int a = 0; a < get_length(); a++) {
                if(hosts[a].name == host_name) {
                    i = a;
                    break;
                }
            }
            if(i != -1) {
                hosts.remove_at(i);
            }
        }

        public Host? get_host_by_name(string name) {
            Host? get_host = null;
            for(int a = 0; a < get_length(); a++) {
                if(hosts[a].name == name) {
                    get_host = hosts[a];
                    break;
                }
            }
            return get_host;
        }

        public Host? get_host(Host host) {
            Host? get_host = null;
            for(int a = 0; a < get_length(); a++) {
                if(hosts[a] == host) {
                    get_host = hosts[a];
                    break;
                }
            }
            return get_host;
        }
    }

    public class HostManager : Object {
        private Group[] groups;


        construct {
            groups = new Group[0];
        }



        public void update_host(string host_name, Host host) {
            for(int i = 0; i < groups.length; i++) {
                var n_host = groups[i].get_host_by_name(host_name);
                if(n_host != null) {
                    var n_group = get_group_by_name (n_host.group);
                    n_group.update_host (host_name, host);
                }
            }
        }

        public void add_group(Group group) {
            groups += group;
        }

        public Group[] get_groups() {
            return groups;
        }

        public bool exist_group(string name) {
            if(groups.length == 0) {
                return false;
            }
            for(int a = 0; a < groups.length; a++) {
                if(groups[a].name == name) {
                    return true;
                }
            }
            return false;
        }

        public Group? get_group_by_name(string name) {
            for(int a = 0; a < groups.length; a++) {
                if(groups[a].name == name) {
                    return groups[a];
                }
            }
            return null;
        }

        public int get_length_hosts(string group_name) {
            for(int a = 0; a < groups.length; a++) {
                if(groups[a].name == group_name) {
                    return groups[a].get_length();
                }
            }
            return 0;
        }

        public Host? get_host(Host host) {
            for(int i = 0; i < groups.length; i++) {
                var n_host = groups[i].get_host(host);
                if(host != null) {
                    return n_host;
                }
            }
            return null;
        }

        public Host? get_host_by_name(string name) {
            for(int i = 0; i < groups.length; i++) {
                var n_host = groups[i].get_host_by_name(name);
                if(n_host != null) {
                    return n_host;
                }
            }
            return null;
        }

        public bool exist_host_name(string name) {
            for(int i = 0; i < groups.length; i++) {
                var n_host = groups[i].get_host_by_name(name);
                if(n_host != null) {
                    return true;
                }
            }
            return false;
        }

        public ArrayList<Granite.Widgets.DynamicNotebook>? get_notebooks() {
            var notebooks = new ArrayList<Granite.Widgets.DynamicNotebook>();
            for(int i = 0; i < groups.length; i++) {
                var hosts = groups[i].get_hosts();
                for(int a = 0; a < hosts.size; a++) {
                    notebooks.add(hosts[a].notebook);
                }
            }
            return notebooks;
        }

    }
}