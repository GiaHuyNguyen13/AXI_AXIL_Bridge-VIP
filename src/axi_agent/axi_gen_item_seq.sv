class axi_gen_item_seq extends uvm_sequence;
  `uvm_object_utils(axi_gen_item_seq)
  function new(string name="axi_gen_item_seq");
    super.new(name);
  endfunction

  bit [6:0] num;
  // num = 1;

  virtual task body();
    for (int i = 0; i < 1; i ++) begin
    	axi_item m_item = axi_item::type_id::create("m_item");
    	start_item(m_item);
    	m_item.randomize();
      finish_item(m_item);
    end
    `uvm_info("SEQ", $sformatf("Done generation of 2 items", num), UVM_LOW)
  endtask
endclass