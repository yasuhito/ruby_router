# -*- coding: utf-8 -*-
require "observer"


class Switch
  def initialize datapath_id
    @datapath_id = datapath_id
    @ports = []
  end
end


#
# Trema/Apps の topology Ruby 版
#
# TODO: それぞれのハンドラのテスト
#
class Topology < Controller
  include Observable


  UINT16_MAX = ( 1 << 16 ) - 1  # FIXME: FLOW_MOD_MAX_PRIORITY?
  OFPFW_ALL = ( 1 << 22 ) - 1  # FIXME
  ETH_ETH_TYPE_LLDP = 0x88cc  # FIXME
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
    @switches.delete datapath_id
    # TODO: スイッチの接続先ポートを確認してサブスクライバに notify
  end


  def features_reply datapath_id, message
    # TODO: スイッチのポート情報を追加してサブスクライバに notify
  end


  # port_status() in topology_management.c
  def port_status datapath_id, message
    case message
    when PortStatusAdd
      # TODO: ポート情報を更新してサブスクライバに notify
    when PortStatusDelete
      # TODO: ポート情報を更新してサブスクライバに notify
    when PortStatusModify
      # TODO: ポート情報を更新してサブスクライバに notify
    else
      raise "Unknown reason"
    end
  end


  ################################################################################
  private
  ################################################################################


  def add_switch datapath_id
    @switches[ datapath_id ] = Switch.new( datapath_id )
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
