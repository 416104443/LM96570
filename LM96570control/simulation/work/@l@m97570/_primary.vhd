library verilog;
use verilog.vl_types.all;
entity LM97570 is
    generic(
        IDLE            : vl_logic_vector(0 to 5) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi1);
        ADDR_OUT        : vl_logic_vector(0 to 5) := (Hi0, Hi0, Hi0, Hi0, Hi1, Hi0);
        DATA_OUT        : vl_logic_vector(0 to 5) := (Hi0, Hi0, Hi0, Hi1, Hi0, Hi0);
        DATA_IN         : vl_logic_vector(0 to 5) := (Hi0, Hi0, Hi1, Hi0, Hi0, Hi0);
        OUT_ACK         : vl_logic_vector(0 to 5) := (Hi0, Hi1, Hi0, Hi0, Hi0, Hi0);
        IN_ACK          : vl_logic_vector(0 to 5) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi0);
        YES             : vl_logic := Hi1;
        NO              : vl_logic := Hi0
    );
    port(
        addr            : in     vl_logic_vector(4 downto 0);
        DATAIN          : in     vl_logic_vector(63 downto 0);
        clk             : in     vl_logic;
        WR              : in     vl_logic;
        RD              : in     vl_logic;
        RST             : in     vl_logic;
        sRD             : in     vl_logic;
        DATAback        : out    vl_logic_vector(63 downto 0);
        ACK             : out    vl_logic;
        sWR             : out    vl_logic;
        sCLK            : out    vl_logic;
        sLE             : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IDLE : constant is 1;
    attribute mti_svvh_generic_type of ADDR_OUT : constant is 1;
    attribute mti_svvh_generic_type of DATA_OUT : constant is 1;
    attribute mti_svvh_generic_type of DATA_IN : constant is 1;
    attribute mti_svvh_generic_type of OUT_ACK : constant is 1;
    attribute mti_svvh_generic_type of IN_ACK : constant is 1;
    attribute mti_svvh_generic_type of YES : constant is 1;
    attribute mti_svvh_generic_type of NO : constant is 1;
end LM97570;
