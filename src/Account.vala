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
    public class Account : Object {

        /* Fields */
        public string name {get; set;}
        public string username {get; set;}
        public string password {get; set;}
        public string identity_file {get; set;}
        public Granite.Widgets.SourceList.Item? item {get; set;}

    }


    public class AccountManager : Object {
        private ArrayList<Account> accounts;

        construct {
            accounts = new ArrayList<Account> ();
        }

        public int get_length() {
            int i = 0;
            foreach (Account account in accounts) {
                if(account != null){
                    i += 1;
                }
            }
            return i;
        }

        public void update_account(string account_name, Account account) {
            for(int a = 0; a < get_length(); a++) {
                if(accounts[a].name == account_name) {
                    accounts[a] = account;
                    break;
                }
            }
        }

        public void add_account(Account account) {
            accounts.add(account);
        }

        public ArrayList<Account> get_accounts() {
            return accounts;
        }

        public void remove_account(string account_name) {
            int i = -1;
            for(int a = 0; a < get_length(); a++) {
                if(accounts[a].name == account_name) {
                    i = a;
                    break;
                }
            }
            if(i != -1) {
                accounts.remove_at(i);
            }
        }


        public Account? get_account_by_name(string name) {
            Account? get_account = null;
            for(int a = 0; a < get_length(); a++) {
                if(accounts[a].name == name) {
                    get_account = accounts[a];
                    break;
                }
            }
            return get_account;
        }

        public Account? get_account(Account account) {
            Account? get_account = null;
            for(int a = 0; a < get_length(); a++) {
                if(accounts[a] == account) {
                    get_account = accounts[a];
                    break;
                }
            }
            return get_account;
        }

        public bool exist_account_name(string name) {
            var n_account = get_account_by_name(name);
            if(n_account != null) {
                return true;
            }
            return false;
        }


    }
}