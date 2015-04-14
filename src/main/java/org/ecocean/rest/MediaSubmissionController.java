package org.ecocean.rest;

import java.util.ArrayList;
import java.util.List;

import javax.servlet.http.HttpServletRequest;

import org.ecocean.ShepherdPMF;
import org.ecocean.SinglePhotoVideo;
import org.ecocean.media.MediaSubmission;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.joda.JodaModule;
import com.samsix.database.ConnectionInfo;
import com.samsix.database.Database;
import com.samsix.database.DatabaseException;
import com.samsix.database.RecordSet;
import com.samsix.database.SqlFormatter;
import com.samsix.database.SqlInsertFormatter;
import com.samsix.database.SqlUpdateFormatter;
import com.samsix.database.SqlWhereFormatter;
import com.samsix.database.Table;

@RestController
@RequestMapping(value = "/obj/mediasubmission")
public class MediaSubmissionController
{
//    static {
//        ObjectMapper mapper = new ObjectMapper();
//        mapper.registerModule(new JodaModule());
//    }
    
    
    public static void save(final Database db,
                            final MediaSubmission media)
        throws
            DatabaseException
    {
        Table table = db.getTable("mediasubmission");
        if (media.getId() == null) {
            SqlInsertFormatter formatter;
            formatter = new SqlInsertFormatter();
            fillFormatter(db, formatter, media);
            media.setId((long)table.insertSequencedRow(formatter, "id"));
        } else {
            SqlUpdateFormatter formatter;
            formatter = new SqlUpdateFormatter();
            formatter.append("id", media.getId());
            fillFormatter(db, formatter, media);
            SqlWhereFormatter where = new SqlWhereFormatter();
            where.append("id", media.getId());
            table.updateRow(formatter.getUpdateClause(), where.getWhereClause());
        }
    }
    
    
    private static void fillFormatter(final Database db,
                                      final SqlFormatter formatter,
                                      final MediaSubmission media)
    {
        formatter.append("description", media.getDescription());
        formatter.append("email", media.getEmail());
        formatter.append("endtime", media.getEndTime());
        formatter.append("latitude", media.getLatitude());
        formatter.append("longitude", media.getLongitude());
        formatter.append("name", media.getName());
        formatter.append("starttime", media.getStartTime());
        formatter.append("submissionid", media.getSubmissionid());
        formatter.append("timesubmitted", media.getTimeSubmitted());
        formatter.append("username", media.getUsername());
        formatter.append("verbatimlocation", media.getVerbatimLocation());
        formatter.append("status", media.getStatus());
    }
    
    
    private static List<MediaSubmission> get(final Database db,
                                             final SqlWhereFormatter where) throws DatabaseException
    {
        List<MediaSubmission> mss = new ArrayList<MediaSubmission>();
        Table table = db.getTable("mediasubmission");
        RecordSet rs = table.getRecordSet(where.getWhereClause());
        while (rs.next()) {
            MediaSubmission ms = new MediaSubmission();
            ms.setDescription(rs.getString("description"));
            ms.setEmail(rs.getString("email"));
            ms.setEndTime(rs.getDateTime("endtime"));
            ms.setId(rs.getLong("id"));
            ms.setLatitude(rs.getDoubleObj("latitude"));
            ms.setLongitude(rs.getDoubleObj("longitude"));
            ms.setName(rs.getString("name"));
            ms.setStartTime(rs.getDateTime("starttime"));
            ms.setSubmissionid(rs.getString("submissionid"));
            ms.setTimeSubmitted(rs.getDateTime("timesubmitted"));
            ms.setUsername(rs.getString("username"));
            ms.setVerbatimLocation(rs.getString("verbatimlocation"));
            ms.setStatus(rs.getString("status"));
            
            mss.add(ms);
        }
        
        return mss;
    }
    
    
//    private final UserService userService;
//
//    @Inject
//    public UserController(final UserService userService) {
//        this.userService = userService;
//    }

    
    @RequestMapping(value = "/get/id/{mediaid}", method = RequestMethod.GET)
    public MediaSubmission get(final HttpServletRequest request,
                               @PathVariable("mediaid")
                               final long mediaid)
        throws DatabaseException
    {
        ConnectionInfo ci = ShepherdPMF.getConnectionInfo();
        
        Database db = new Database(ci);
        
        try {
            SqlWhereFormatter where = new SqlWhereFormatter();
            where.append("id", mediaid);
            List<MediaSubmission> mss = get(db, where);
            
            if (mss.size()==0) {
                return null;
            }
            
            MediaSubmission ms = mss.get(0);
            
            //
            // Now fill the medias.
            //
            String sql = "SELECT spv.* FROM mediasubmission_media m"
                    + " INNER JOIN \"SINGLEPHOTOVIDEO\" spv ON spv.\"DATACOLLECTIONEVENTID\" = m.mediaid"
                    + " WHERE m.mediasubmissionid = " + mediaid;
            RecordSet rs = db.getRecordSet(sql);
            List<SinglePhotoVideo> spvs = new ArrayList<SinglePhotoVideo>();
            while (rs.next()) {
                SinglePhotoVideo media = new SinglePhotoVideo();
                media.setDataCollectionEventID(rs.getString("DATACOLLECTIONEVENTID"));
                media.setCopyrightOwner(rs.getString("COPYRIGHTOWNER"));
                media.setCopyrightStatement(rs.getString("COPYRIGHTSTATEMENT"));
                media.setCorrespondingStoryID(rs.getString("CORRESPONDINGSTORYID"));
                media.setCorrespondingUsername(rs.getString("CORRESPONDINGUSERNAME"));
                media.setFilename(rs.getString("FILENAME"));
                media.setFullFileSystemPath(rs.getString("FULLFILESYSTEMPATH"));
                spvs.add(media);
            }
            ms.setMedia(spvs);
            
            return ms;
        } finally {
            db.release();
        }
    }

    
    @RequestMapping(value = "/get/status", method = RequestMethod.GET)
    public List<MediaSubmission> getStatus(final HttpServletRequest request)
        throws DatabaseException
    {
        return getStatus(request, null);
    }
    
    
    @RequestMapping(value = "/get/status/{status}", method = RequestMethod.GET)
    public List<MediaSubmission> getStatus(final HttpServletRequest request,
                                           @PathVariable("status")
                                           final String status)
        throws DatabaseException
    {
        ConnectionInfo ci = ShepherdPMF.getConnectionInfo();
        
        Database db = new Database(ci);
        
        try {
            SqlWhereFormatter where = new SqlWhereFormatter();
            // * will mean get all, so we just have an empty where formatter
            // we want all other values, included null, to pass to the append method
            if (! "*".equals(status)) {
                where.append("status", status);
            }
            return get(db, where);
        } finally {
            db.release();
        }
    }
    
    
    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public long save(final HttpServletRequest request,
                     final MediaSubmission media)
        throws DatabaseException
    {
//        //
//        // Save using DataNucleus for now?
//        //
//        Shepherd myShepherd = new Shepherd(ServletUtilities.getContext(request));
        ConnectionInfo ci = ShepherdPMF.getConnectionInfo();
        
        Database db = new Database(ci);
        
        try {
            //
            // Save media submission
            //
//            boolean isNew = (media.getId() == null);

            save(db, media);

            //
            // TODO: This code works as is EXCEPT due to the stupid IDX ordering column
            // that DataNucleus put on our SURVEY_MEDIA table along with making SURVEY_ID_OID/IDX being
            // the primary key (Why?!!!) we can't just add 0 for the IDX column. Sheesh.
            // Recreate the SURVEY_MEDIA table the way you want it and fix this later.
            //
//            if (isNew) {
//                //
//                // Check if the media submissionId matches a survey and if so
//                // insert into SURVEY_MEDIA table.
//                // TODO: Add a parameter to the save method to indicate that this
//                // media submission was intended for a survey so that we know if
//                // we should be doing this or something else with the submissionId.
//                //
//                RecordSet rs;
//                SqlWhereFormatter where = new SqlWhereFormatter();
//                where.append("SURVEYID"), media.getSubmissionid());
//                
//                rs = db.getTable("SURVEY").getRecordSet(where.getWhereClause());
//                if (rs.next()) {
//                    SqlInsertFormatter formatter;
//                    formatter = new SqlInsertFormatter();
//                    formatter.append("SURVEY_ID_OID"), rs.getInteger("SURVEY_ID"));
//                    formatter.append("ID_EID"), media.getId());
//                    formatter.append("IDX"), 0);
//                    db.getTable("SURVEY_MEDIA").insertRow(formatter);                
//                }
//            }
            
            return media.getId();
        } finally {
            db.release();
        }
        
//        PersistenceManager pm = myShepherd.getPM();
////        MediaSubmission ms;
////        if (media.getId() != null) {
////            ms = ((MediaSubmission) (pm.getObjectById(pm.newObjectIdInstance(MediaSubmission.class, media.getId()), true)));
////            //
////            // TODO: Switch to regular SQL!!!
////            // Now I would have to go through all of the properties on the media and set
////            // them to the current one?! WTF.
////            //
////        } else {
////            ms = media;
////        }
//        
//        if (media.getSubmissionid() != null) {
////            survey = ((Survey) (pm.getObjectById(pm.newObjectIdInstance(Survey.class, media.getSubmissionid()), true)));
//            Query query = pm.newQuery(
//                    "SELECT FROM \"SURVEY\" WHERE \"SURVEYID\" == '" + media.getSubmissionid() + "'");
//                @SuppressWarnings("unchecked")
//                List<Survey> results = (List<Survey>)query.execute();
//                if (results.size() > 0) {
//                    Survey survey = results.get(0);
//                    survey.getMedia().add(media);
//                    pm.makePersistent(survey);
//                } else {
//                    pm.makePersistent(media);
//                }
//        } else {
//            pm.makePersistent(media);
//        }
////        myShepherd.beginDBTransaction();
////        myShepherd.getPM().makePersistent(media);
////        myShepherd.commitDBTransaction();
    }
    
//    @RequestMapping(value = "/get/{id}", method = RequestMethod.GET)
//    public MediaSubmission save(final MediaSubmission media,
//                         @ParamField("id") int id ) {
//        
//        System.out.println(media);
//    }

    
//    //
//    // Just test stuff
//    //
//    @RequestMapping(value = "/upload", method = RequestMethod.POST)
//    public UploadResult uploadMedia(@RequestBody @Valid final UploadData data) {
//        return new UploadResult("hello, I am the upload");
//    }
//    
//    @RequestMapping(value = "/test", method = RequestMethod.POST)
//    public @ResponseBody UploadResult test(@RequestParam(value="data") final String data) {
//      String value = "hello, test with data [" + data + "]"; 
//      UploadResult upload = new UploadResult(value);
//      return upload;
//    }
//
//    @RequestMapping(value = "/test2", method = RequestMethod.POST)
//    public int test2() {
//        return 42;
//    }
//
//    @RequestMapping(value = "/test2b", method = RequestMethod.GET)
//    public UploadResult test2b() {
//        return new UploadResult("junk");
//    }
//
//    @RequestMapping(value = "/test2b", method = RequestMethod.POST)
//    public UploadResult test2b(UploadResult stuff) {
//        return new UploadResult("junk " + stuff.value);
//    }
//
//    @RequestMapping(value = "/test3", method = RequestMethod.POST)
//    public String test3(@RequestParam(value="data") final String data) {
//      String value = "hello, test with data [" + data + "]"; 
//      UploadResult upload = new UploadResult(value);
//      return upload.value;
//    }
//
//    @RequestMapping(value = "/test4", method = RequestMethod.POST)
//    public UploadResult test4(@RequestParam(value="data") final String data) {
//      String value = "hello, I am the test4 with [data=" + data + "]"; 
//      UploadResult upload = new UploadResult(value);
//      return upload;
//    }
//
//    @RequestMapping(value = "/test5", method = RequestMethod.POST)
//    public String test5(HttpServletRequest request,
//                        @RequestParam(value="data") final String data) {
//      String context = ServletUtilities.getContext(request);
//      String value = "hello, test with data ["
//          + data
//          + "] and mail host ["
//          + CommonConfiguration.getMailHost(context)
//          + "]"; 
//      UploadResult upload = new UploadResult(value);
//      return upload.value;
//    }

//    public static class UploadResult {
//        public String value;
//      
//        public UploadResult()
//        {
//            //un-marshalling
//        }
//      
//        public UploadResult(final String value)
//        {
//            this.value = value;
//        }
//      
//        public String getValue()
//        {
//            return value;
//        }
//      
//        public void setValue(final String value)
//        {
//            this.value = value;
//        }
//    }
//    
//    public static class UploadData {
//        public int id;
//        public String value;
//    }
}
