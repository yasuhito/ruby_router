#
# Copyright (C) 2008-2012 NEC Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#


class TopologySwitch < Switch
  def start
    info "Started (dpid=#{ @dpid.to_hex })."
  end


  def controller_connected
    info "Connected to a controller."
  end


  def hello xid, version
    info "Hello (xid=#{ xid }, version=#{ version })."
    send_message Hello.new( xid )
  end


  def features_request xid
    info "Features Request (xid=#{ xid })."
    send_message FeaturesReply.new( :datapath_id => @dpid, :transaction_id => xid )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
