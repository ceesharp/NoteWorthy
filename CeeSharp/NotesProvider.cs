using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace CeeSharp
{
    /// <summary>
    /// Author: Teah Elaschuk
    /// 
    /// A static class to provide standard access the musical alphabet, intervals,
    /// and its notes across the application.
    /// </summary>
    public static class NotesProvider
    {
        public static Note A = new Note("A");
        public static Note Ash = new Note("A#");
        public static Note B = new Note("B");
        public static Note C = new Note("C");
        public static Note Csh = new Note("C#");
        public static Note D = new Note("D");
        public static Note Dsh = new Note("D#");
        public static Note E = new Note("E");
        public static Note F = new Note("F");
        public static Note Fsh = new Note("F#");
        public static Note G = new Note("G");
        public static Note Gsh = new Note("G#");

        /// <summary>
        /// A list containing all the notes in the musical alphabet
        /// </summary>
        public static List<Note> Notes = new List<Note> { A, Ash, B, C, Csh, D, Dsh, E, F, Fsh, G, Gsh };

        /// <summary>
        /// Author: Teah Elaschuk
        /// 
        /// used to find the target note from the previous, by finding the nth semitone.
        /// </summary>
        /// <param name="prev"></param>
        /// <param name="dist"></param>
        /// <returns></returns>
        public static Note GetTarget(Note prev, int dist)
        {
            int i = Notes.IndexOf(prev);
            if ((i += dist) > 11)           // the interval may be larger than the index of the alphabet. if so, return to the beginning.
            {
                i -= 12;
            }
            return Notes[i];
        }

        /// <summary>
        /// Author: Teah Elaschuk
        /// 
        /// Finds the note object using the name.
        /// </summary>
        /// <param name="s"></param>
        /// <returns></returns>
        public static Note GetNoteByName(string s)
        {
            foreach(Note n in Notes)
            {
                if (n.Name == s)
                    return n;
            }
            return null;
        }
    }

    /// <summary>
    /// Author: Teah Elaschuk
    /// 
    /// An individual Note object.    /// 
    /// This class was built with future expansion in mind. 
    /// </summary>
    public class Note
    {
        public string Name { get; }
        public Note(string n)
        {
            Name = n;
        }
    }
}