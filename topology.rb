# -*- coding: utf-8 -*-
# TODO: それぞれのハンドラのテスト


class Topology < Controller
  UINT16_MAX = ( 1 << 16 ) - 1  # FIXME: FLOW_MOD_MAX_PRIORITY?
  OFPFW_ALL = ( 1 << 22 ) - 1  # FIXME
  OFPFW_DL_TYPE = 1 << 4  # FIXME
  ETH_ETH_TYPE_LLDP = 0x88cc  # FIXME
  INITIAL_DISCOVERY_PERIOD = 5


  def start
    @switches = []
  end


  def switch_ready datapath_id
    @switches << datapath_id
    send_flow_mod_add(
      datapath_id,
      :priority => UINT16_MAX,
      :hard_timeout => INITIAL_DISCOVERY_PERIOD,
      :match => Match.new( :wildcards => OFPFW_ALL & ~OFPFW_DL_TYPE, :dl_type => ETH_ETHTYPE_LLDP ),
      :actions => ActionOutput.new( :port => OFPP_CONTROLLER, :max_len => UINT16_MAX )
    )
    send_flow_mod_add(
      datapath_id,
      :priority => UINT16_MAX - 1,
      :hard_timeout => INITIAL_DISCOVERY_PERIOD,
      :match => Match.new( :wildcards => OFPFW_ALL )
    )
  end


  def switch_disconnected datapath_id
    # switch_disconnected() in topology_management.c
  end


  def features_reply datapath_id, message
    # switch_features_reply() in topology_management.c
  end


  # port_status() in topology_management.c
  def port_status datapath_id, message
    case message
    when PortStatusAdd
      # TODO
    when PortStatusDelete
      # TODO
    when PortStatusModify
      # TODO
    else
      raise "Unknown reason"
    end
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
