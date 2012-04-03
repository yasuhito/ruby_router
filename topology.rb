# -*- coding: utf-8 -*-
require "observer"


class TopologyPort
  def initialize port
    @port = port
  end


  def up?
    @port.up?
  end


  def down
    # TODO
  end
end


class TopologySwitch
  attr_reader :ports


  def initialize datapath_id
    @datapath_id = datapath_id
    @ports = []
  end


  def add port
    @ports << port
  end


  def delete port
    port.down
    @ports -= [ port ]
  end


  def find port
    candidate = nil
    @ports.each do | each |
      if port.name.nil?
        return each if each.number == port.number
      else
        return each if each.name == port.name
        if each.number == port.number
          candidate = each
        end
      end
    end
    candidate
  end
end


#
# Trema/Apps の topology Ruby 版
#
# TODO: それぞれのハンドラのテスト
#
class TopologyController < Controller
  include Observable


  UINT16_MAX = ( 1 << 16 ) - 1  # FIXME: FLOW_MOD_MAX_PRIORITY?
  OFPFW_ALL = ( 1 << 22 ) - 1  # FIXME
  ETH_ETHTYPE_LLDP = 0x88cc  # FIXME
  INITIAL_DISCOVERY_PERIOD = 5


  def start
    @switches = {}
  end


  def switch_ready datapath_id
    add_switch datapath_id
    add_flow_for_receiving_lldp datapath_id
    add_flow_for_discarding_every_other_packet datapath_id
    send_message datapath_id, FeaturesRequest.new
  end


  def switch_disconnected datapath_id
    ports( datapath_id ).each do | each |
      @switches[ datapath_id ].delete each
      changed
      notify_observers datapath_id, each
    end
    delete_switch datapath_id
  end


  def features_reply datapath_id, message
    message.ports.each do | each |
      @switches[ datapath_id ].add TopologyPort.new( each )
      changed
      notify_observers datapath_id, each
    end
  end


  def port_status datapath_id, message
    switch = @switches[ datapath_id ]
    case message
      when PortStatusAdd
        switch.add TopologyPort.new( message.phy_port )
        changed
      when PortStatusDelete
        switch.delete switch.find( message.phy_port )
        changed
      when PortStatusModify
        if switch.find( message.phy_port ).number != message.phy_port.number
          switch.delete switch.find( message.phy_port )
          switch.add TopologyPort.new( message.phy_port )
          changed
        else
          if switch.find( message.phy_port ).name != message.phy_port.name
            switch.find( message.phy_port ).name = message.phy_port.name
          end
          changed
        end
      else
        raise "Unknown reason"
    end
    notify_observers datapath_id, switch.find( message.phy_port )
  end


  ################################################################################
  private
  ################################################################################


  def add_switch datapath_id
    info "New Switch (datapath_id = #{ datapath_id.to_hex })."
    @switches[ datapath_id ] = TopologySwitch.new( datapath_id )
  end


  def delete_switch datapath_id
    @switches.delete datapath_id
  end


  def ports datapath_id
    if @switches[ datapath_id ]
      return @switches[ datapath_id ].ports
    end
    []
  end


  def add_flow_for_receiving_lldp datapath_id
    send_flow_mod_add(
      datapath_id,
      :priority => UINT16_MAX,
      :hard_timeout => INITIAL_DISCOVERY_PERIOD,
      :match => Match.new( :dl_type => ETH_ETHTYPE_LLDP ),
      :actions => ActionOutput.new( :port => OFPP_CONTROLLER, :max_len => UINT16_MAX )
    )
  end


  def add_flow_for_discarding_every_other_packet datapath_id
    send_flow_mod_add(
      datapath_id,
      :priority => UINT16_MAX - 1,
      :hard_timeout => INITIAL_DISCOVERY_PERIOD,
      :match => Match.new( :wildcards => OFPFW_ALL )  # FIXME: "すべてにマッチ" って簡単に書けない？
    )
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
