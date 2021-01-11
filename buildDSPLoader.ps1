f = open(r'\Users\john-mchugh\Documents\Analog Devices\SigmaStudio 4.5\RPI\params\params.params')
data = f.readlines()
elems = []
pos = 0
midi_pos = 0
type_pos = 1
id_pos = 2
min_pos = 3
max_pos = 4
format_pos = 5
midi = "midi"
osc = "osc"
oscm = "oscm"
oscf = "filtf"
knob = "knob"
pad = "pad"
midi_osc = "midi_osc"
midi_oscm = "midi_oscm"
midi_oscf = "midi_oscf"
midi_knob = "midi_knob"
midi_pad = "midi_pad"
midi_adsr = "midi_adsr"
midi_vel = "midi_vel"
midi_filtf = "midi_filtf"
filtf = "filtf"
adsr = "adsr"
vel = "vel"
adsr_addr = "aAddr"
vel_addr = "vAddr"
filtf_addr = "fAddr"
elem_addr = "addr"

cell_name = "Cell Name"
param_name = "Parameter Name"
param_add = "Parameter Address"
param_val = "Parameter Value"
inc = "inc"
dcInput = "DCInp"
cur = -1
ignoreblock = True
oscblock = False

class melem:
	def __init__(self):
		self.mtype = ""
		self.faddr = ""
		self.vaddr = ""
		self.aaddr = ""
		self.id = ""
		self.min = ""
		self.max = ""
		self.format = "824"
		self.writeXML = True

for line in data:
	v = line.split("=")
	if len(v) > 1:
		#print(v[1], end='')
		if v[0].find(cell_name) > -1:
			if v[1].find(midi) > -1:
				ignoreblock = False
				oscblock = False
				e = melem()
				elems.append(e)
				cur = len(elems) - 1
				desc = v[1].split("_")
				if len(desc) > 1:
					for d in desc:
						if d.find(midi) > -1:
							pos = type_pos
						elif pos == type_pos:
							if d.find(oscm) > -1:
								e.mtype = midi_oscm
								pos = id_pos
							elif d.find(oscf) > -1:
								e.mtype = midi_oscf
								pos = id_pos
							elif d.find(osc) > -1:
								e.mtype = midi_osc
								pos = id_pos
							elif d.find(knob) > -1:
								e.mtype = midi_knob
								pos = id_pos
							elif d.find(pad) > -1:
								e.mtype = midi_pad
								pos = id_pos
							elif d.find(adsr) > -1:
								e.mtype = midi_adsr
								e.writeXML = False
								pos = id_pos
							elif d.find(vel) > -1:
								e.mtype = midi_vel
								e.writeXML = False
								pos = id_pos
							elif d.find(filtf) > -1:
								e.mtype = midi_filtf
								e.writeXML = False
								pos = id_pos
						elif pos == id_pos:
							e.id = d.strip()
							pos = min_pos
						elif pos == min_pos:
							e.min = d.strip()
							pos = max_pos
						elif pos == max_pos:
							e.max = d.strip()
							pos = format_pos
						elif pos == format_pos:
							e.format = d.strip()
			else:
				ignoreblock = True
		elif not ignoreblock and cur > -1 and v[0].find(param_name) > -1:
			if elems[cur].mtype == midi_osc or elems[cur].mtype == midi_oscm or elems[cur].mtype == midi_oscf:
				if v[1].find(inc) == -1 and v[1].find(dcInput) == -1:
					elems.pop(cur)
					ignoreblock = True
		elif not ignoreblock and cur > -1 and v[0].find(param_add) > -1:
			elems[cur].addr = v[1].strip()
		elif not ignoreblock and cur > -1 and v[0].find(param_val) > -1:
			elems[cur].val = v[1].strip()

def getOscElem(i):
	for e in elems:
		#print("try " + e.mtype + " with id:" + str(e.id))
		if e.mtype == midi_osc and e.id == i:
			return e

for e in elems:
	if e.mtype == midi_adsr:
		#print("find osc for adsr with id:" + str(e.id))
		o = getOscElem(e.id)
		o.aaddr = e.addr
	elif e.mtype == midi_vel:
		o = getOscElem(e.id)
		o.vaddr = e.addr
	elif e.mtype == midi_filtf:
		o = getOscElem(e.id)
		o.faddr = e.addr

w = open(r'\Users\john-mchugh\Documents\Analog Devices\SigmaStudio 4.5\RPI\params\paramsdat.txt', 'w')
w.write('<beometa>\n')
w.write('sampleRate:48000\n')
w.write('filtFMulti:12\n')

def eqq(v):
	return ":" + v + ","	

for e in elems:
	if not e.writeXML:
		continue
	#print(e.mtype, e.id, e.min, e.max, e.format, "addr", e.addr, "vel", e.vaddr, "adsr", e.aaddr)
	#msg = "    <metadata synth" + eqq(e.mtype) + " " + adsr_addr + " " + eqq(e.aaddr) + " " + vel_addr + eqq(e.vaddr)
	#msg = msg + " min" + eqq(e.min) + " max" + eqq(e.max) + " format" + eqq(e.format) + " midi_id" + eqq(e.id)
	#msg = msg + ">" + e.addr + "</metadata>\n"
	msg = e.mtype + "," + elem_addr + eqq(e.addr) + filtf_addr + eqq(e.faddr) + adsr_addr + eqq(e.aaddr) + vel_addr + eqq(e.vaddr)
	msg = msg + "min" + eqq(e.min) + "max" + eqq(e.max)
	msg = msg + "format" + eqq(e.format) + "midi_id:" + e.id + '\n'
	w.write(msg)
w.write('<program>\n')

nb = open(r'\Users\john-mchugh\Documents\Analog Devices\SigmaStudio 4.5\RPI\params\NumBytes_IC_1.dat')
txf = open(r'\Users\john-mchugh\Documents\Analog Devices\SigmaStudio 4.5\RPI\params\TxBuffer_IC_1.dat')
bdata = nb.readlines()
tx = txf.readlines()
c = 0
for line in bdata:
	b = int(line.split(',')[0])
	a = tx[c].split(',')
	w.write(str(b) + '\n')
	w.write(str(int(a[0], 16)) + ',' + str(int(a[1], 16)) + '\n')
	#w = [0, int(a[0], 16), int(a[1], 16)]
	b = b-2
	while b > 0:
		c = c + 1
		tdata = tx[c].split(',')
		r = len(tdata) - 1
		for d in range(r):
			b = b - 1
			#w.append(int(tdata[d], 16))
			w.write(str(int(tdata[d], 16)))
			if d < r - 1:
				w.write(',')
		w.write('\n')
	#if w[1] + w[2] == 0:
		#time.sleep(0.1)
		#print("delay")
	#else:
		#dsp.xfer(w)
		#print(w)
	c = c + 1
	
		