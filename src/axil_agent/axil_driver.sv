class driver extends uvm_driver #(item);              
  `uvm_component_utils(driver)
  function new(string name = "driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction
  
  virtual vir_interface vif;
  
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual vir_interface)::get(this, "", "vir_interface", vif))
      `uvm_fatal("DRV", "Could not get vif")
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      item m_item;
      `uvm_info("DRV", $sformatf("Wait for item from sequencer"), UVM_HIGH)
      seq_item_port.get_next_item(m_item); // get next item
      drive_item(m_item); // forward item to DUT through interface
      seq_item_port.item_done(); // item get done
    end
  endtask
  

  virtual task drive_item(item m_item);
    
  endtask
endclass