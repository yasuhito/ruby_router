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


class TopologySwitch < Trema::Switch
  def start
    info "Started"
  end


  def controller_connected
    info "Connected to a controller."
  end


  def hello xid, version
    info "Hello (xid=#{ xid }, version=#{ version })"
    send_message Trema::Hello.new( xid )
  end


  def features_request xid
    info "Features Request (xid=#{ xid })"
    send_message Trema::FeaturesReply.new( 
      :datapath_id => @dpid,
      :transaction_id => xid,
      :n_buffers => 256,
      :n_tables => 2,
      :capabilities => 135,
      :actions => 2047,
      :ports => []
    )
  end


  def echo_request xid, body
    info "Echo Request (xid=#{ xid }, body=\"#{ body }\")"
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
