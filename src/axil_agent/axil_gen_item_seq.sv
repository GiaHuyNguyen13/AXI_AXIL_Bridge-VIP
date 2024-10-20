class axil_gen_item_seq extends uvm_sequence;
  `uvm_object_utils(axil_gen_item_seq)
  function new(string name="axil_gen_item_seq");
    super.new(name);
  endfunction

  rand bit [6:0] num;

  virtual task body();
  `uvm_info("SEQ", $sformatf("Done generation of 1 items"), UVM_LOW)
    for (int i = 0; i < 1; i ++) begin
    	axil_item m_item = axil_item::type_id::create("m_item");
    	start_item(m_item);
    	m_item.randomize();
      finish_item(m_item);
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass