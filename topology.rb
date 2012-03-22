# -*- coding: utf-8 -*-
# TODO: それぞれのハンドラのテスト


class Topology < Controller
  def switch_ready datapath_id
    # handle_switch_ready() in topology_management.c
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
