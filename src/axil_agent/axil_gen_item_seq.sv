class axil_gen_item_seq extends uvm_sequence;
  `uvm_object_utils(axil_gen_item_seq)
  function new(string name="axil_gen_item_seq");
    super.new(name);
  endfunction

  rand bit [6:0] num;
  rand bit op;

  virtual task body();
    for (int i = 0; i < num; i ++) begin
    	axil_item m_item = axil_item::type_id::create("m_item");
    	start_item(m_item);
    	m_item.randomize() with {
        operation == op;
      };
      finish_item(m_item);
    end
    `uvm_info("SEQ", $sformatf("Done generation of %0d items", num), UVM_LOW)
  endtask
endclass