class M6502
  def initialize(address = 0x0200)
    @a = 0
    @x = 0
    @y = 0
    @s = 0xff
    
    @n = 0
    @v = 0
    @b = 0
    @d = 0
    @i = 0
    @z = 0
    @c = 0
    
    @pc = address
    @memory = [
      0xA9, 0x80
    ]
    @instructions = {
      0x09 => [:ora, :immediate]
      0x29 => [:and, :immediate]
      0x49 => [:eor, :immediate]
      0x69 => [:adc, :immediate]
      0xa0 => [:ldy, :immediate]
      0xa2 => [:ldx, :immediate]
      0xa9 => [:lda, :immediate]
      0xc9 => [:cmp, :immediate]
      0xe9 => [:sbc, :immediate]
    }
  end
  def executeInstruction
    instruction = @memory[@pc]
    @pc += 1
    microcode = @instructions[instruction]
    operation = microcode[0]
    mode = microcode[1]
    send(operation, mode)
  end
  def display
    puts "A=0x#{@a.to_s(16)}"
    puts "X=0x#{@x.to_s(16)}"
    puts "Y=0x#{@y.to_s(16)}"
    puts "S=0x#{@s.to_s(16)}"
    puts "P=#{@n}#{@v}#{@b}#{@d}#{@i}#{@z}#{@c}"
    puts "pc=0x#{@pc.to_s(16)}"
  end

  def lda(mode)
    @a = send(mode)
    @z = @a.zero? ? 1 : 0
    @n = (@a >> 7).zero? ? 0 : 1
  end
  
  def immediate
    @pc += 1
    return @memory[@pc - 1]
  end
end

m6502 = M6502.new(0)
m6502.executeInstruction
m6502.display