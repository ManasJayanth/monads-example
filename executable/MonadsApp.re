module type MONAD = {
  type t('a);
  let return: 'a => t('a);
  let (>>=): (t('a), 'a => t('b)) => t('b);
};

module type Operations = {
  include MONAD;
  let read: unit => t(string);
  let write: string => t(unit);
  let run: t('a) => 'a;
};

module Operations = {
  type t('a) = unit => (unit, 'a);
  let read = ((), ()) => ((), read_line());
  let write = (buf, ()) => ((), print_string(buf));
  let return = (v, ()) => ((), v);
  let (>>=) = (m, k, ()) => {
    let ((), v) = m();
    k(v, ());
  };
  let run = m => {
    let ((), v) = m();
    v;
  };
};

let () = {
  open Operations;

  let readLine1 = () => read();
  let readLine2 = () => read();
  let displayTheTwoLines = (lineA, lineB) => {
    write(Printf.sprintf("You entered two lines:\n%s \n%s\n", lineA, lineB));
  };

  /* Let's just print whatever your computation
     returns */
  run(
    readLine1()
    >>= (
      lineA => {
        readLine2()
        >>= (
          lineB => {
            displayTheTwoLines(lineA, lineB)
            >>= (() => displayTheTwoLines("foo", "bar"));
          }
        );
      }
    ),
  );
};
