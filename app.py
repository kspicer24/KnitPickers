from flask import Flask, request, render_template, url_for, session, flash
from flaskext.mysql import MySQL
from werkzeug.utils import redirect
from datetime import date

from classes import *

app = Flask(__name__)
#  change info here to access database on your own server
app.config['MYSQL_DATABASE_USER'] = 'root'
app.config['MYSQL_DATABASE_PASSWORD'] = '504Washington'
app.config['MYSQL_DATABASE_DB'] = 'projectdatabasespicerk'
app.config['MYSQL_DATABASE_HOST'] = 'localhost'
mySql = MySQL(app)

app.secret_key = 'asdsdfsdfs13sdf_df%&'

app.listOfYarn = []
app.listOfPatterns = []


@app.route("/", methods=['GET', 'POST'])
def main():
    login_stat = False
    yarn = []
    if 'username' in session:
        login_stat = True

    # get fillers for select drop downs- pass through render like login

    # categories
    cursor = mySql.connect().cursor()
    stmt = 'SELECT category FROM pattern GROUP BY category'
    cursor.execute(stmt)
    rows = cursor.fetchall()
    print('categories: ', rows)
    categories = ['select option']
    for row in rows:
        categories.append(row[0])
    cursor.close()

    # stash info if logged in -- registered user feature
    if login_stat:
        cursor = mySql.connect().cursor()
        stmt = 'call getStash(%s)'
        cursor.execute(stmt, session['username'])
        rows = cursor.fetchall()
        yarn = [['select', 'option']]
        for row in rows:
            yarn.append([row[0], row[1]])  # adds brand/style

    # apply filter if apply button is pressed
    if request.method == 'POST':
        if 'filter_results' in request.form:
            patterns = []
            myyarn = None
            stitch = request.form['stitch_type']
            if stitch == '1':
                stitch = 'Knit'
            elif stitch == '2':
                stitch = 'Crochet'
            else:
                stitch = None
            category = request.form['category_type']
            if category == 'select option':
                category = None

            if 'username' in session:
                myyarn = request.form['yarn_select'].split('|')
                if myyarn == ['select', 'option']:
                    myyarn = None

            # build query statement based on filled in information
            extraClause = None
            arguments = []
            addStmt = 'WHERE '

            if stitch is not None:
                if len(arguments) > 0:
                    addStmt += "AND "
                addStmt += 'stitchType =  %s '
                arguments.append(stitch)

            if category is not None:
                if len(arguments) > 0:
                    addStmt += 'AND '
                addStmt += 'category = %s '
                arguments.append(category)

            if myyarn is not None:
                # get yarnID from brand/style listed in select
                yarnCursor = mySql.connect().cursor()
                stmt = 'SELECT getYarnID(%s, %s)'
                yarnCursor.execute(stmt, (myyarn[0], myyarn[1]))
                yarnID = yarnCursor.fetchone()[0]
                yarnCursor.close()

                # now requires join- set that up
                extraClause = 'JOIN (SELECT pattern FROM uses WHERE yarn = %s) as y ON patternID = pattern'
                newArgs = [yarnID]
                newArgs += arguments
                arguments = newArgs

            finalQuery = 'SELECT patternID, patternName, stitchType, category, patternFile, text_desc, poster FROM '

            # logic to build final query statement to fetch data
            if len(addStmt) > 6:
                if extraClause is not None:
                    finalQuery += '(SELECT * FROM pattern ' + addStmt + ') as p ' + extraClause
                else:
                    finalQuery += 'pattern ' + addStmt
            else:
                if extraClause is not None:
                    finalQuery += 'pattern ' + extraClause
                else:
                    finalQuery = 'SELECT * FROM pattern'

            # execute query and get filtered patterns
            patterncursor = mySql.connect().cursor()
            patterncursor.execute(finalQuery, tuple(arguments))
            rows = patterncursor.fetchall()

            # add query results to list of pattern objects to populate the website
            for row in rows:
                tempPattern = Pattern(row[0], row[1], row[2], row[3], row[4], row[5], row[6])
                patterns.append(tempPattern)
                print(tempPattern.url)

            patterncursor.close()
            print('patterns: ', patterns)

            # making it global allows view pattern to access the pattern when 'view details' is clicked
            app.listOfPatterns = patterns

            return render_template('main_site.html', login=login_stat, categories=categories, stash_yarn=yarn,
                                   patterns=app.listOfPatterns)

    # build list of all patterns if no filter is selected
    patterns = []
    patcursor = mySql.connect().cursor()
    stmt = 'SELECT * FROM pattern'
    patcursor.execute(stmt)
    rows = patcursor.fetchall()

    # add patterns to list to send to html
    for row in rows:
        tempPattern = Pattern(row[0], row[1], row[2], row[3], row[5], row[6], row[4])
        patterns.append(tempPattern)
        print(tempPattern.url)

    app.listOfPatterns = patterns

    return render_template('main_site.html', login=login_stat, categories=categories, stash_yarn=yarn,
                           patterns=app.listOfPatterns)


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form["username"]
        password = request.form["password"]
        cursor = mySql.connect().cursor()

        # check validity of username/password
        query = 'SELECT checkLogin(%s, %s);'
        cursor.execute(query, (username, password))
        value = cursor.fetchone()

        # if valid go back to main page all logged in
        if value[0] == 1:
            # add username to session- indicates logged in
            session['username'] = username

            # get name for session
            stmt = 'SELECT fName FROM user_member WHERE username = %s'
            nameCursor = mySql.connect().cursor()
            nameCursor.execute(stmt, username)
            name = nameCursor.fetchone()[0]
            if name is not None:
                session['name_of_user'] = name

            return redirect(url_for('main'))

        flash('invalid username or password')
    return render_template('log_in.html')


@app.route('/logout')
def logout():
    # remove username from session- logged out
    session.pop('username', None)
    session.pop('name_of_user', None)
    return redirect(url_for('main'))


@app.route('/create_acct', methods=['GET', 'POST'])
def createAccount():
    if request.method == 'POST':
        # gather variables from submitted form
        username = request.form["username"]
        password = request.form["password"]
        name = request.form["firstName"]

        # check valid username
        cursor = mySql.connect().cursor()
        query = 'SELECT checkUniqueUsername(%s);'
        cursor.execute(query, username)
        value = cursor.fetchone()
        cursor.close()
        if value[0] == 1:  # valid username, add to DB and login

            # if valid, add to database so they can log in in the future
            mycursor = mySql.connect().cursor()
            stmt = "INSERT INTO user_member (username, pword, fName) VALUES(%s, %s, %s);"
            mycursor.execute(stmt, (username, password, name))
            mycursor.connection.commit()
            mycursor.close()

            # log them in and return to main page
            session['username'] = username
            if name is not None:
                session['name_of_user'] = name
            return redirect(url_for('main'))

    return render_template('create_acct.html')


@app.route("/profile", methods=['GET', 'POST'])
def toProfile():
    if request.method == 'POST':

        # delete pattern if button is pressed
        if 'delete_pattern' in request.form:

            # get pattern ID from hidden form
            patternid = request.form['pattern_details']
            if patternid == '':    # error control
                flash('unable to delete pattern')
                return redirect(url_for('toProfile'))

            # delete from database
            delpattern = mySql.connect().cursor()
            stmt = 'SELECT deletePattern(%s)'
            delpattern.execute(stmt, patternid)
            delpattern.connection.commit()

            # rebuild profile without deleted pattern
            return redirect(url_for('toProfile'))

    # get patterns they've posted
    patternCursor = mySql.connect().cursor()
    stmt = 'SELECT * FROM pattern WHERE poster = %s'
    patternCursor.execute(stmt, session['username'])
    rows = patternCursor.fetchall()
    patternCursor.close()
    print('rows: ', rows)
    # add pattern objects to global list of patterns- global makes accessible to viewPattern
    app.listOfPatterns = []
    for row in rows:
        tempPattern = Pattern(row[0], row[1], row[2], row[3], row[5], row[6], row[4])
        app.listOfPatterns.append(tempPattern)

    print(app.listOfPatterns)
    return render_template('view_profile.html', patterns=app.listOfPatterns)


@app.route("/queue", methods=['GET', 'POST'])
def toQueue():
    # remove from queue if remove button is pressed
    if request.method == 'POST':
        if 'remove_from_queue' in request.form:

            # get patternID from hidden form and user info from session
            patternID = request.form['patternInfo']  # wont be invalid if presented on screen
            user = session['username']  # page only accessible if logged in

            # remove pattern from queues in database
            remQCursor = mySql.connect().cursor()
            stmt = 'DELETE FROM queues WHERE patternID = %s AND username = %s'
            remQCursor.execute(stmt, (patternID, user))
            remQCursor.connection.commit()
            remQCursor.close()

            # rebuild page without pattern
            return redirect(url_for('toQueue'))

    # get queue from database ordered by position asc
    queueCursor = mySql.connect().cursor()
    stmt = 'call getQueue(%s)'
    queueCursor.execute(stmt, session['username'])

    app.listOfPatterns = []
    rows = queueCursor.fetchall()
    queueCursor.close()

    # add pattern objects to global list of patterns
    for row in rows:
        tempPattern = Pattern(row[0], row[1], row[2], row[3], row[5], row[6], row[4])
        app.listOfPatterns.append(tempPattern)

    return render_template('queue.html', patterns=app.listOfPatterns)


@app.route("/stash", methods=['GET', 'POST'])
def toStash():

    # handle form submissions
    if request.method == 'POST':
        # add yarn to stash
        if 'add_to_stash' in request.form:
            # get values from form
            brand = request.form['yarn_brand'].lower()  # lower provides consistency in database
            style = request.form['yarn_style'].lower()
            # TODO incorporate color- dont worry about yards
            color = request.form['yarn_color']

            if brand is None or style is None:  # control for user input
                flash('brand and style must be filled out to add yarn to stash')
                return redirect(url_for('toStash'))

            # check if yarn exists in database
            createExistsCursor = mySql.connect().cursor()
            stmt = 'SELECT checkYarnExists(%s, %s);'
            createExistsCursor.execute(stmt, (brand, style))
            yarnID = createExistsCursor.fetchone()[0]

            if yarnID == -1:  # doesn't exist in database
                # add yarn to yarn table
                createYarnCursor = mySql.connect().cursor()
                stmt = 'INSERT INTO yarn (brand, style) VALUES (%s, %s);'
                createYarnCursor.execute(stmt, (brand, style))
                createYarnCursor.connection.commit()

                # get that yarnID
                yarnIDCursor = mySql.connect().cursor()
                stmt = 'SELECT getYarnID(%s, %s);'
                yarnIDCursor.execute(stmt, (brand, style))
                yarnID = yarnIDCursor.fetchall()[0]
                yarnIDCursor.close()

            # add yarnID and other info to user's stash TODO add color
            stashCursor = mySql.connect().cursor()
            stmt = 'INSERT INTO stash (username, yarn, color) VALUES (%s, %s, %s);'
            stashCursor.execute(stmt, (session['username'], yarnID, color))
            stashCursor.connection.commit()
            stashCursor.close()

            # rebuild page with new yarn added to list
            return redirect(url_for('toStash'))

        # user clicked to delete yarn from their stash
        if 'delete_from_stash' in request.form:
            yarnInfo = request.form['yarnInfo'].split("|")  # gets brand and style

            if yarnInfo is None:  # error control
                flash('could not delete yarn')
                return redirect(url_for('toStash'))

            # get yarnID
            brand = yarnInfo[0]
            style = yarnInfo[1]
            idCursor = mySql.connect().cursor()
            stmt = 'SELECT getYarnID(%s, %s)'
            idCursor.execute(stmt, (brand, style))
            yarnID = idCursor.fetchone()[0]
            idCursor.close()

            if yarnID == -1:  # yarn doesn't exist in database- handle it
                flash('issue deleting yarn')
                return redirect(url_for('toStash'))

            # delete from stash, but keep in yarn
            delCursor = mySql.connect().cursor()
            stmt = 'DELETE FROM stash WHERE username = %s AND yarn = %s'
            delCursor.execute(stmt, (session['username'], yarnID))
            delCursor.connection.commit()
            delCursor.close()

            # rebuild page without deleted yarn
            return redirect(url_for('toStash'))

    # no button pressed
    else:
        # get all of users stash to populate list
        cursor = mySql.connect().cursor()
        stmt = 'call getStash(%s);'
        stash = []
        cursor.execute(stmt, session['username'])
        rows = cursor.fetchall()
        cursor.close()

        # create list of yarn objects to populate list of stash
        for row in rows:
            tempYarn = Yarn(row[0], row[1], row[2])
            stash.append(tempYarn)

        # build page with stash
        return render_template('stash.html', stash=stash)


@app.route("/add_pattern", methods=['GET', 'POST'])
def addPattern():

    if request.method == 'POST':
        if 'add_yarn_to_pattern' in request.form:  # clicked button to add yarn to the pattern
            # gather info from form
            brand = request.form['yarn_brand'].lower()
            style = request.form['yarn_style'].lower()

            if brand is None or style is None:  # user input control
                flash('brand, and style must be filled in to add yarn to pattern')
                return redirect(url_for('addPattern'))


            # create yarn object
            myYarn = Yarn(brand, style, None)
            if myYarn is None:
                flash('could not add yarn')
                session['pName'] = request.form['pattern_name']
                session['stitch'] = request.form['stitch_type']
                session['category'] = request.form['category']
                return redirect(url_for(addPattern))

            # add to global list of yarn
            app.listOfYarn.append(myYarn)

            # add session variables to preserve filled out info after redirect
            session['pName'] = request.form['pattern_name']
            session['stitch'] = request.form['stitch_type']
            session['category'] = request.form['category']

            return redirect(url_for('addPattern'))

        elif 'submit_form' in request.form:  # clicked button to submit pattern
            # add yarns to db- keep track of yarnIDs in a list
            yarnIds = []
            for yarn in app.listOfYarn:
                # check if yarn exists
                createExistsCursor = mySql.connect().cursor()
                stmt = 'SELECT checkYarnExists(%s, %s);'
                createExistsCursor.execute(stmt, (yarn.brand, yarn.style))
                yarnID = createExistsCursor.fetchone()[0]  # checkYarnExists returns either the yarnID or -1

                if yarnID == -1:  # yarn is not in database
                    # add yarn to yarn table
                    createYarnCursor = mySql.connect().cursor()
                    stmt = 'INSERT INTO yarn (brand, style) VALUES (%s, %s);'
                    createYarnCursor.execute(stmt, (yarn.brand, yarn.style))
                    createYarnCursor.connection.commit()

                    # get that yarnID
                    yarnIDCursor = mySql.connect().cursor()
                    stmt = 'SELECT getYarnID(%s, %s);'
                    yarnIDCursor.execute(stmt, (yarn.brand, yarn.style))
                    yarnID = yarnIDCursor.fetchall()[0]
                    yarnIDCursor.close()

                yarnIds.append(yarnID)

            # add pattern to DB
            name = request.form['pattern_name']
            if len(name) >= 50:  # control for potential mysql error
                flash('pattern name must be less than 22 characters')
                return redirect(url_for('addPattern'))

            # make sure name is unique, if not- flash error
            patternCursor = mySql.connect().cursor()
            stmt = 'SELECT getPatternID(%s);'
            patternCursor.execute(stmt, name)
            value = patternCursor.fetchone()[0]
            patternCursor.close()

            if value != -1:
                flash('pattern name is not unique!')
                return redirect(url_for('addPattern'))

            stitch = request.form['stitch_type']
            if stitch == '--select option--':
                stitch = None

            category = request.form['category']

            text = request.form['text_description']
            if len(text) > 1000:  # control for user input/potential mysql error
                text = text[:1001]

            data = request.form['site_url']  # input set up for url- will control for that
            if data == '':  # url must be included
                flash('no url for pattern given!')
                return redirect(url_for('addPattern'))

            # add pattern to database
            instPatternCursor = mySql.connect().cursor()
            insertstmt = 'INSERT INTO pattern (patternName, stitchType, category, poster, patternFile, ' \
                         'text_desc) VALUES (%s, %s, %s, %s, %s, %s); '
            instPatternCursor.execute(insertstmt, (name, stitch, category, session['username'], data, text))
            instPatternCursor.connection.commit()
            instPatternCursor.close()

            # add yarns to uses
            # get pattern ID
            pCursor = mySql.connect().cursor()
            getID = 'SELECT getPatternID(%s);'
            pCursor.execute(getID, name)
            patternID = pCursor.fetchone()[0]
            pCursor.close()

            if patternID == -1:  # pattern wasn't successfully inserted
                flash('upload unsuccessful')
                return redirect(url_for('addPattern'))

            # loop to add all yarn to uses
            usesStmt = 'INSERT INTO uses (pattern, yarn) VALUES (%s, %s);'
            for i in range(len(app.listOfYarn)):
                tempCursor = mySql.connect().cursor()
                if type(yarnIds[i]) == tuple:
                    yarnIds[i] = yarnIds[i][0]
                tempCursor.execute(usesStmt, (int(patternID), int(yarnIds[i])))
                tempCursor.connection.commit()
                tempCursor.close()

            # reset session variables
            session['pName'] = ''
            session['stitch'] = ''
            session['category'] = ''
            app.listOfYarn = []
            return redirect(url_for('main'))

        elif 'cancel_form' in request.form:  # user pressed button to cancel
            # reset yarn list and session variables
            app.listOfYarn = []
            session['pName'] = ''
            session['stitch'] = ''
            session['category'] = ''

            # redirect to main
            return redirect(url_for('main'))

    else:  # no button pressed, just render form with list of yarn
        return render_template('add_pattern.html', yarns=app.listOfYarn)


@app.route('/view_pattern', methods=['GET', 'POST'])
def viewPattern():
    # get patternID from passed through variables- tells us which pattern to display
    pattID = int(request.args.get('pattID'))
    myPattern = None

    # build the pattern with the appropriate id
    for pattern in app.listOfPatterns:  # get the pattern in the global list of patterns
        if pattern.pid == pattID:
            myPattern = pattern
            break

    if myPattern is None:  # error control
        flash('Error Loading Pattern')
        return redirect(url_for('main'))

    if request.method == 'POST':
        # users have the option to edit their description here if its a pattern they posted
        if 'submit_description' in request.form:  # user submitted a new description
            new_text = request.form['text_description']

            if len(new_text) > 1000:  # controls for potential mysql error
                flash('description too long- must be less than 1000 characters')
                return redirect(url_for('viewPattern', pattID=pattID))

            # update description in database
            updatecursor = mySql.connect().cursor()
            stmt = "UPDATE pattern SET text_desc = %s WHERE patternID = %s"
            updatecursor.execute(stmt, (new_text, pattID))
            updatecursor.connection.commit()
            updatecursor.close()

            return redirect(url_for('viewPattern', pattID=pattID))

        if "post_comment" in request.form:  # user posted comment on pattern
            # get comment from form
            comment = request.form['text_description']

            if comment == '':  # empty comments don't make sense..
                print('no comment written')
                return redirect(url_for('viewPattern', pattID=pattID))

            if len(comment) > 280:  # control for length- length inspired by twitter
                print('comment too long- must be less than 280 characters')
                return redirect(url_for('viewPattern', pattID=pattID))

            # prep other variables for database
            myDate = date.today()
            user = session['username']

            # add comment to comments_on in database
            commentCursor = mySql.connect().cursor()
            stmt = 'INSERT INTO comments_on (username, pattern, user_comment, comment_date) VALUES (%s, %s, %s, %s)'
            commentCursor.execute(stmt, (user, pattID, comment, myDate))
            commentCursor.connection.commit()
            commentCursor.close()

            # reload page with comment added
            return redirect(url_for('viewPattern', pattID=pattID))

        # if the comment was posted by the active user, they can delete it here
        if "delete_comment" in request.form:  # user pressed delete on their comment
            delComment = request.form['comment']

            if delComment is None:  # control for error
                flash('could not delete comment')
                return redirect(url_for('viewPattern'))

            # delete comment from database
            delcursor = mySql.connect().cursor()
            stmt = 'DELETE FROM comments_on WHERE username = %s AND pattern = %s AND user_comment = %s'
            delcursor.execute(stmt, (session['username'], pattID, delComment))
            delcursor.connection.commit()
            delcursor.close()

            # rebuild page without deleted comment
            return redirect(url_for('viewPattern', pattID=pattID))

        # logged in users can add the pattern to their queue here
        if "add_to_queue" in request.form:  # user pressed add to queue
            # check if in queue
            cursor = mySql.connect().cursor()
            stmt = 'SELECT checkQueue(%s, %s)'
            cursor.execute(stmt, (pattID, session['username']))
            value = cursor.fetchone()[0]

            if value == -1:  # already in queue
                flash('pattern already in queue')
                return redirect(url_for('viewPattern', pattID=pattID))

            else:  # not yet in queue
                # add to queue
                queueCursor = mySql.connect().cursor()
                stmt = 'INSERT INTO queues (username, patternID, position) VALUES (%s, %s, %s)'
                queueCursor.execute(stmt, (session['username'], pattID, value))
                queueCursor.connection.commit()

            return redirect(url_for('viewPattern', pattID=pattID))

    else:  # no button pressed, standard build page

        # build yarn list
        app.listOfYarn = []
        useCursor = mySql.connect().cursor()
        stmt = 'call getUsedYarn(%s)'
        useCursor.execute(stmt, myPattern.pid)
        rows = useCursor.fetchall()
        useCursor.close()

        # add yarn objects to global list
        for row in rows:
            tempYarn = Yarn(row[0], row[1], None)
            app.listOfYarn.append(tempYarn)

        # build comment list
        getCommentCursor = mySql.connect().cursor()
        stmt = 'call getComments(%s)'
        getCommentCursor.execute(stmt, pattID)
        comments = []
        rows = getCommentCursor.fetchall()
        getCommentCursor.close()

        # build list of comments for view
        for row in rows:
            tempComment = Comment(row[0], row[1], row[2])
            comments.append(tempComment)

    return render_template('view_pattern.html', pattern=myPattern, yarns=app.listOfYarn, comments=comments)
