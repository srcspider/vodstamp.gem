class Vodstamp

	VERSION = '0.1.0'

#### Commands ##################################################################

	def version(args)
		puts "  #{Vodstamp::VERSION}"
	end#def

	def all(args)
		msg "filtering all from [#{args[0]}] to [#{args[1]}]"

		inputfile = File.expand_path(args[0]);
		outputfile = File.expand_path(args[1]);

		if ! File.exist? inputfile
			err "The file [#{inputfile}] does not exist."
		end

		rawlog = File.read inputfile
		rawlog = rawlog.split "\n"

		log = filter_chatlog true, rawlog, arg[2]

		File.write(outputfile, log.join("\n"))
		msg "fin"
	end#def

	def filter(args)
		msg "filtering [#{args[0]}] to [#{args[1]}] using source [#{args[2]}]"

		inputfile = File.expand_path(args[0]);
		outputfile = File.expand_path(args[1]);

		if ! File.exist? inputfile
			err "The file [#{inputfile}] does not exist."
		end

		rawlog = File.read inputfile
		rawlog = rawlog.split "\n"

		filter_chatlog false, rawlog, args[2]

		File.write(outputfile, log.join("\n"))
		msg "fin"
	end#def

	def build(args)
		msg "building from [#{args[0]}] to [#{args[1]}] with splits [#{args[2]}] and offset of #{args[3]} seconds"

		inputfile = File.expand_path(args[0]);
		outputfile = File.expand_path(args[1]);
		splitsfile = File.expand_path(args[2]);

		if ! File.exist? inputfile
			err "The file [#{inputfile}] does not exist."
		end

		if ! File.exist? splitsfile
			err "The file [#{splitsfile}] does not exist."
		end

		rawlog = File.read inputfile
		rawlog = rawlog.split "\n"

		rawsplits = File.read splitsfile
		rawsplits = rawsplits.split "\n"

		timestamps = build_timestamps rawlog, rawsplits, args[3].to_i

		File.write(outputfile, timestamps.join("\n"))
		msg "fin"
	end#def

#### Working Methods ###########################################################

	def build_timestamps(rawlog, rawsplits, offset)
		# parse timestamps
		logpattern = /[a-zA-Z]+ [0-9]+ ([0-9]{2}):([0-9]{2}):([0-9]{2}) <([a-zA-Z0-9_-]+)> \[timestamp\] (T-([0-9]{2}):([0-9]{2}) (.*)|ignore last|todo|realign)/
		log = [];
		diff = nil
		rawlog.each do |line|
			match = logpattern.match(line)
			next if match[6] == nil
			# get data
			h = match[1].to_i
			m = match[2].to_i
			s = match[3].to_i
			om = match[6].to_i
			os = match[7].to_i
			message = match[8]
			# convert to seconds
			time_s = s + m * 60 + h * 60 * 60
			offset_s = os + om * 60

			if diff === nil
				diff = time_s - offset_s
			end

			time_s = time_s - offset_s - diff
			log.push({ time: time_s, msg: message })
		end#each

		# parse splits
		splitpattern = /([a-zA-Z0-9 ]+)\. ([0-9]{2}):([0-9]{2}):([0-9]{2})/
		splits = []
		rawsplits.each do |line|
			match = splitpattern.match(line)
			h = match[2].to_i
			m = match[3].to_i
			s = match[4].to_i
			# convert to seconds
			time_s = s + m * 60 + h * 60 * 60
			splits.push({ time: time_s, name: match[1] })
		end#each

		# generate timestamps
		times = []
		splitidx = 0
		this_split = splits[splitidx]
		split_max_time = this_split[:time]
		split_diff = -offset
		times.push([]);
		log.each do |entry|
			if offset + entry[:time] > split_max_time
				split_diff += this_split[:time]
				splitidx += 1
				this_split = splits[splitidx]
				split_max_time += this_split[:time]
				times.push([])
			end
			times[splitidx].push({ time: entry[:time] - split_diff, msg: entry[:msg] })
		end#each

		timestamps = []
		idx = 0

		print "  " # progress prefix
		times.each do |stamps|
			timestamps.push " -- #{splits[idx][:name]} -- "
			stamps.each do |time|
				minutes = (time[:time] / 60).to_i
				seconds = time[:time] - minutes * 60
				timestamps.push readable_time(time[:time]) + " #{time[:msg]}"
				print '.' # progress indicator
			end#each
			idx += 1
		end#each
		puts

		return timestamps;
	end#def

	def filter_chatlog(all_messages, rawlog, source = nil)
		log = []

		if all_messages
			logpattern = /.* \[timestamp\] .*/
		else # only correct ones
			logpattern = /[a-zA-Z]+ [0-9]+ ([0-9]{2}):([0-9]{2}):([0-9]{2}) <([a-zA-Z0-9_-]+)> \[timestamp\] (T-([0-9]{2}):([0-9]{2}) .*|ignore last|todo|realign)/
		end

		ignorepattern = /\[timestamp\] ignore last/

		print "  " # progress prefix
		rawlog.each do |line|
			if (match = logpattern.match(line)) != nil
				if all_messages || match[4] == source
					if ! all_messages && ignorepattern.match(line) != nil
						log.pop
						print ',' # indicate backtracking
					else # normal line
						log.push line
						print '.' # indicate progress
					end
				end
			end
		end#each
		puts # new line at end of progress

		return log
	end#def

#### Helpers ###################################################################

	def readable_time(time)
		hours = (time / 3600).to_i
		minutes = ((time - hours) / 60).to_i
		seconds = time - hours * 3600 - minutes * 60
		if hours != 0
			return ('%02d' % hours) + ':' + ('%02d' % minutes) + ':' + ('%02d' % seconds)
		else
			return ('%02d' % minutes) + ':' + ('%02d' % seconds)
		end
	end#def

	def err(msg)
		puts "  Err: #{msg}"
		exit
	end#def

	def msg(msg)
		puts "  #{msg}"
	end#def

end#class
