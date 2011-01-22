class M6502
  def initialize(address = 0x0200)
    @a = 0
    @x = 0
    @y = 0

    # previous values for lazy evaluation of flags
    @oa = 0
    @ox = 0
    @oy = 0

    @s = 0xff
    
    @n = @v = @b = @d = @i = @z = @c = 0
    
    @pc = address
    @memory = [
      0xa9, 0x00, #lda 0x00
      0x69, 0x80,
      0x00
    ]
    @opcodes = {
      #adc
      0x69 => [:adc, :immediate],
      0x65 => [:adc, :zeropage],
      0x75 => [:adc, :zeropagex],
      0x6d => [:adc, :absolute],
      0x7d => [:adc, :absolutex],
      0x79 => [:adc, :absolutey],
      0x61 => [:adc, :indirectx],
      0x71 => [:adc, :indirecty],

      #and
      0x29 => [:and, :immediate],
      0x25 => [:and, :zeropage],
      0x35 => [:and, :zeropagex],
      0x2d => [:and, :absolute],
      0x3d => [:and, :absolutex],
      0x39 => [:and, :absolutey],
      0x21 => [:and, :indirectx],
      0x31 => [:and, :indirecty],

      # asl
      0x0a => [:asl, :accumulator],
      0x06 => [:asl, :zeropage],
      0x16 => [:asl, :zeropagex],
      0x0e => [:asl, :absolute],
      0x1e => [:asl, :absolutex],

      # bit
      0x24 => [:bit, :zeropage],
      0x2c => [:bit, :absolute],

      # branch
      0x10 => [:bpl, :relative],
      0x30 => [:bmi, :relative],
      0x50 => [:bvc, :relative],
      0x70 => [:bvs, :relative],
      0x90 => [:bcc, :relative],
      0xB0 => [:bcs, :relative],
      0xd0 => [:bne, :relative],
      0xf0 => [:beq, :relative],

      # cmp
      0xc9 => [:cmp, :immediate],
      0xc5 => [:cmp, :zeropage],
      0xd5 => [:cmp, :zeropagex],
      0xcd => [:cmp, :absolute],
      0xdd => [:cmp, :absolutex],
      0xd9 => [:cmp, :absolutey],
      0xc1 => [:cmp, :indirectx],
      0xd1 => [:cmp, :indirecty],

      # cpx
      0xe0 => [:cpx, :immediate],
      0xe4 => [:cpx, :zeropage],
      0xec => [:cpx, :absolute],

      # cpy
      0xc0 => [:cpy, :immediate],
      0xc4 => [:cpy, :zeropage],
      0xcc => [:cpy, :absolute],

      # dec
      0xc6 => [:dec, :zeropage],
      0xd6 => [:dec, :zeropagex],
      0xce => [:dec, :absolute],
      0xde => [:dec, :absolutex],

      # eor
      0x49 => [:eor, :immediate],
      0x45 => [:eor, :zeropage],
      0x55 => [:eor, :zeropagex],
      0x4d => [:eor, :absolute],
      0x5d => [:eor, :absolutex],
      0x59 => [:eor, :absolutey],
      0x41 => [:eor, :indirectx],
      0x51 => [:eor, :indirecty],

      # processor status
      0x18 => [:clc, :implied],
      0x38 => [:sec, :implied],
      0x58 => [:cli, :implied],
      0x78 => [:sei, :implied],
      0xb8 => [:clv, :implied],
      0xd8 => [:cld, :implied],
      0xf8 => [:sed, :implied],

      # inc
      0xe6 => [:inc, :zeropage],
      0xf6 => [:inc, :zeropagex],
      0xee => [:inc, :absolute],
      0xfe => [:inc, :absolutex],

      # jmp
      0x4c => [:jmp, :absolute],
      0x6c => [:jmp, :indirect],

      # jsr
      0x20 => [:jsr, :absolute],

      # lda
      0xa9 => [:lda, :immediate],
      0xa5 => [:lda, :zeropage],
      0xb5 => [:lda, :zeropagex],
      0xad => [:lda, :absolute],
      0xbd => [:lda, :absolutex],
      0xb9 => [:lda, :absolutey],
      0xa1 => [:lda, :indirectx],
      0xb1 => [:lda, :indirecty],

      # ldx
      0xa2 => [:ldx, :immediate],
      0xa6 => [:ldx, :zeropage],
      0xb6 => [:ldx, :zeropagey],
      0xae => [:ldx, :absolute],
      0xbe => [:ldx, :absolutey],

      # ldy
      0xa0 => [:ldy, :immediate],
      0xa4 => [:ldy, :zeropage],
      0xb4 => [:ldy, :zeropagex],
      0xac => [:ldy, :absolute],
      0xbc => [:ldy, :absolutex],

      # lsr
      0x4a => [:lsr, :accumulator],
      0x46 => [:lsr, :zeropage],
      0x56 => [:lsr, :zeropagex],
      0x4e => [:lsr, :absolute],
      0x5e => [:lsr, :absolutex],

      # nop
      0xea => [:nop, :implied],

      # ora
      0x09 => [:ora, :immediate],
      0x05 => [:ora, :zeropage],
      0x15 => [:ora, :zeropagex],
      0x0d => [:ora, :absolute],
      0x1d => [:ora, :absolutex],
      0x19 => [:ora, :absolutey],
      0x01 => [:ora, :indirectx],
      0x11 => [:ora, :indirecty],

      # processor status
      0xaa => [:tax, :implied],
      0x8a => [:txa, :implied],
      0xca => [:dex, :implied],
      0xe8 => [:inx, :implied],
      0xa8 => [:tay, :implied],
      0x98 => [:tya, :implied],
      0x88 => [:dey, :implied],
      0xc8 => [:iny, :implied],

      # rol
      0x2a => [:rol, :accumulator],
      0x26 => [:rol, :zeropage],
      0x36 => [:rol, :zeropagex],
      0x2e => [:rol, :absolute],
      0x3e => [:rol, :absolutex],

      # ror
      0x6a => [:ror, :accumulator],
      0x66 => [:ror, :zeropage],
      0x76 => [:ror, :zeropagex],
      0x6e => [:ror, :absolute],
      0x7e => [:ror, :absolutex],

      # rti
      0x40 => [:rti, :implied],

      # rts
      0x60 => [:rts, :implied],

      # sbc
      0xe9 => [:sbc, :immediate],
      0xe5 => [:sbc, :zeropage],
      0xf5 => [:sbc, :zeropagex],
      0xed => [:sbc, :absolute],
      0xfd => [:sbc, :absolutex],
      0xf9 => [:sbc, :absolutey],
      0xe1 => [:sbc, :indirectx],
      0xf1 => [:sbc, :indirecty],

      # sta
      0x85 => [:sta, :zeropage],
      0x95 => [:sta, :zeropagex],
      0x8d => [:sta, :absolute],
      0x9d => [:sta, :absolutex],
      0x99 => [:sta, :absolutey],
      0x81 => [:sta, :indirectx],
      0x91 => [:sta, :indirecty],

      # stack instructions
      0x9a => [:txs, :implied],
      0xba => [:tsx, :implied],
      0x48 => [:pha, :implied],
      0x68 => [:pla, :implied],
      0x08 => [:php, :implied],
      0x28 => [:plp, :implied],

      # stx
      0x86 => [:stx, :zeropage],
      0x96 => [:stx, :zeropagey],
      0x8e => [:stx, :absolute],

      # sty
      0x84 => [:sty, :zeropage],
      0x94 => [:sty, :zeropagex],
      0x8c => [:sty, :absolute],
    }
  end
  def executeInstruction
    opcode = @memory[@pc]
    @pc += 1
    # have to deal with break specially as a key of 0 comes back as a NilClass
    if(opcode.zero?)
      brk
      true
    else
      instruction = @opcodes[opcode]
      op = instruction[0]
      mode = instruction[1]
      puts "op=#{op} mode=#{mode}"
      send(op, send(mode))
      false
    end
  end
  def display
    puts "A=0x#{@a.to_s(16)}"
    puts "X=0x#{@x.to_s(16)}"
    puts "Y=0x#{@y.to_s(16)}"
    puts "S=0x#{@s.to_s(16)}"
    puts "P=#{@n}#{@v}#{@b}#{@d}#{@i}#{@z}#{@c}"
    puts "pc=0x#{@pc.to_s(16)}"
  end

  def brk
    @b = 1
    @i = 1
  end

  def adc(value)
    @oa = @a
    @a = (@a + value) & 0xff
  end

  def lda(value)
    @oa = @a
    @a = value
  end
  
  def ldx(value)
    @ox = @x
    @x = value
  end
  
  def ldy(value)
    @oy = @y
    @y = value
  end

  # modes

  def immediate
    value = @memory[@pc]
    @pc += 1
    return value
  end
  
  def zeropage
    index = @memory[@pc]
    @pc += 1
    return @memory[index]
  end
  
  def zeropagex
    index = @memory[@pc]
    @pc += 1
    return @memory[index + @x]
  end
  
  def zeropagey
    index = @memory[@pc]
    @pc += 1
    return @memory[index + @y]
  end
end

m6502 = M6502.new(0)
begin
  brk = m6502.executeInstruction
  m6502.display
end until brk
