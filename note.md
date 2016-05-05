# RPC

    09:58:19< braunr> LastAvengers: glibc isn't required to perform rpcs, it's just that it's the best place to put many of them that implement the posix stuff existing applications expect
    09:58:45< braunr> LastAvengers: but yes, basically, you send a request, and you get a reply, as in any other rpc system
    09:59:08< braunr> LastAvengers: the thing is, mach has its own capability terminology, that you need to understand

# Port, right and name

    10:03:24< braunr> LastAvengers: a port is a global object that lives in the kernel
    10:03:37< braunr> the kernel guarantees safe access to it
    10:03:58< braunr> that is, it can be accessed from any task, but only through a right, on which the kernel enforces verification
    10:04:06< braunr> that's the concept of a capability, a reference-right
    10:04:19< braunr> rights belong to tasks

    10:04:33< braunr> and names are integer identifiers for rights
    10:04:36< braunr> like file descriptors
    10:04:53< braunr> so basically, when you see a mach_port_t in userspace, think name
    10:04:58< braunr> think "int fd;"

    10:05:11< braunr> the name denotes a right in your local task (inside its ipc space)
    10:05:17< braunr> and the right denotes a port
    10:05:25< braunr> the port has a message queue
    10:05:39< braunr> sending a message to a port enqueues a message, receiving dequeues
    10:05:54< braunr> there can be only one receive right, and any number of send rights
    10:06:13< braunr> the task that owns the receive right implements the associated object
    10:06:24< braunr> tasks owning send rights can invoke that object remotely, through rpcs
    10:06:39< braunr> here, you have most of the terminology and associations involved

    10:07:46< braunr> LastAvengers: FYI, ports a non first-class object, since you can never manipulate them directly
    10:07:56< braunr> LastAvengers: while rights (through names) are first class objects
    10:08:16< braunr> that fact that rights are local (task-local) restricts what tasks can do
    10:08:26< braunr> the fact that ports are global allows tasks to communicate with one another
    10:09:29< LastAvengers> braunr: hmm... "the receive right implements the associated object", what is this object?
    10:09:38< braunr> i'm not sure that kind of school is allowed :/ but check anyway
    10:09:47< braunr> LastAvengers: anything, like files
    10:09:49< braunr> or sockets
    10:09:51< braunr> or anything else realy
    10:10:15< braunr> really*
    10:10:33< braunr> LastAvengers: that's how mach achieves its goal of system extensibility

    10:10:49< LastAvengers> so, port and translatore are no concepts on the same level?
    10:11:00< braunr> like i said, forget about the word "translator"
    10:11:10< braunr> when you read translator, think "server implementing objects"
    10:11:31< braunr> it's a fancy but confusing name
    10:11:36< braunr> and its utility is debatable
    10:11:50< braunr> all translators are servers, but not all servers are translators
    10:12:14< braunr> what turns a server into a translator is the fact that the server is attached to the file system
    10:12:31< braunr> and "translates" file system operations into object-specific operatios
    10:12:34< braunr> operations*
    10:12:45< braunr> like ftpfs turns regular file access into ftp access
    10:13:05< braunr> another way to put it is translator == fuse++
    10:13:26< braunr> now, since translators are servers, they use ports
    10:13:36< braunr> through rights
    10:13:48< braunr> receive rights to receive object invocations
    10:14:01< braunr> and send rights for everything else (replies, forwarding, etc..)
    10:14:47< braunr> LastAvengers: it's close to what unix does with files
    10:14:52< braunr> int fd is the name
    10:14:56< LastAvengers> well, understand a little...

    10:15:08< braunr> on the kernel side, an open file descriptor is the right
    10:15:24< braunr> and inside the file system, you have your object
    10:15:36< braunr> which isn't the same whether you have ext4fs or procfs or nfs for example
    10:15:43< braunr> but in unix, "everything is a file"
    10:15:58< braunr> whereas with mach, you really have naked objects, and you can turn them into files if you want
    10:16:12< LastAvengers> name is the represents of right, is it right?
    10:16:12< braunr> or into objects with another interface
    10:16:17< braunr> yes

    10:17:08< DusXMT> LastAvengers: I wonder, did you read the "Mach Kernel Principles" document? Helped me understand the system quite a bit
    10:18:11< DusXMT> you can find it here: https://gnu.org/software/hurd/microkernel/mach/documentation.html
    10:18:58< LastAvengers> DusXMT: thx, I will see it.
    10:19:26< LastAvengers> it looks quite long...
    10:19:47< braunr> which is why i explained some of the things here directly instead of redirecting you

    10:22:41< LastAvengers> braunr: in *nix, we can handle a file with a fd, can we handle file (or other object) with name?
    10:23:04< braunr> yes
    10:23:24< braunr> the main difference is that, on unix, since everything is a file, everything supports the file interface
    10:23:41< braunr> whereas on mach, each object has its own set of interfaces that it implements
    10:23:41< LastAvengers> so, does function open() return a "name" but not fd?
    10:23:44< braunr> and it may not be a file
    10:23:56< braunr> no, open is the posix stuff
    10:24:02< braunr> that glibc provides
    10:24:06< braunr> it returns an fd
    10:24:23< braunr> but internally, glibc associates these file descriptors with names
    10:25:34< LastAvengers> well, these name operation are do behind glibc for POSIX-compliant.
    10:25:47< braunr> yes
    10:27:40< DusXMT> yet

    10:28:24< braunr> LastAvengers: the hurd variant of open is dir_lookup
    10:28:31< braunr> LastAvengers: part of the fs interface
    10:28:41< braunr> you can find the fs interface in hurd/fs.defs
    10:29:28< LastAvengers> so it is... in xv6, dir_lookup only used to find a inode.
    10:29:48< braunr> xv6 is a very simple unix
    10:29:51< braunr> but the idea is the same yes
    10:30:06< braunr> dir_lookup finds an object
    10:30:26< braunr> the fact that there is an inode becomes an implementation detail specific to that object
    10:31:07< braunr> hm
    10:31:09< braunr> one second :p
    10:32:05< braunr> it's bit more complicated than that
    10:32:22< LastAvengers> braunr: can not understand. ^ (inode and object)
    10:32:34< braunr> an inode is the real stuff on your file system
    10:32:43< braunr> an object is something vague :p
    10:32:48< braunr> thinkg object oriented programming
    10:33:23< braunr> ok so
    10:33:32< LastAvengers> yse, and some fs has no inode.
    10:33:35< braunr> the real function doing the work of open is file_name_lookup
    10:33:38< braunr> LastAvengers: yes
    10:33:48< braunr> file_name_lookup is implemented by glibc, on top of dir_lookup and others
    10:34:41< braunr> LastAvengers: it's just that, since xv6 is meant to be simple, all this layer of complexity goes away
    10:34:53< braunr> and a function like dir_lookup then directly finds an inode
    10:34:57< DusXMT> LastAvengers: the "object" is not something real, it's just a concept used to identify "something that has a state and an interface". A filesystem has a state (the storage) and an interface (the filesystem operations), so a filesystem can be considered an object, and a filesystem server provides this object
    10:36:01< braunr> LastAvengers: you can also see that, when i compared with unix (fd = name and open file = right), i made no analogy for ports
    10:36:15< LastAvengers> DusXMT: got it.
    10:36:30< braunr> unix has nothing like ports because everything is the kernel, you don't need to add something to make external tasks implement objects
    10:45:56< braunr> DusXMT: thanks for the explanation
    10:46:06< braunr> i'd just add that an object can have multiple interfaces
    10:46:22< DusXMT> np
    10:46:49< braunr> LastAvengers: i'll be out for a while, chew on all this, it's important that it makes sense to you, and don't hesitate to ask questions
    10:48:06< braunr> i think next years, we'll make sure students understand this before they get accepted, as part of the communit bonding period
    10:50:00< LastAvengers> well.
